package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use constant DEVICE_PER_MESSAGE => 4;

use English qw(-no_match_vars);
use Net::IP;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Recipient::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::XML::Query;

our $VERSION = $FusionInventory::Agent::VERSION;

sub isEnabled {
    my ($self, %params) = @_;

    return unless
        $self->{controller}->isa('FusionInventory::Agent::Controller::Server');

    my $response = $params{response};

    my $options = $self->getOptionsFromServer(
        $response, 'NETDISCOVERY', 'NetDiscovery'
    );
    return unless $options;

    if (!$options->{RANGEIP}) {
        $self->{logger}->debug("No IP range defined in the prolog response");
        return;
    }

    $self->{options} = $options;
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("running FusionInventory NetDiscovery task");

    # use given output recipient,
    # otherwise assume the recipient is a GLPI server
    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Server->new(
            target       => $self->{controller}->getUrl(),
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
        );

    my $options     = $self->{options};
    my $pid         = $options->{PARAM}->[0]->{PID};
    my $max_threads = $options->{PARAM}->[0]->{THREADS_DISCOVERY};
    my $timeout     = $options->{PARAM}->[0]->{TIMEOUT};

    # check discovery methods available
    my ($nmap_parameters, $snmp_credentials, $snmp_dictionary);

    if (canRun('nmap')) {
       my ($major, $minor) = getFirstMatch(
           command => 'nmap -V',
           pattern => qr/Nmap version (\d+)\.(\d+)/
       );
       $nmap_parameters = compareVersion($major, $minor, 5, 29) ?
           "-sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms " :
           "-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 "       ;
    } else {
        $self->{logger}->info(
            "Can't run nmap, nmap detection can't be used"
        );
    }

    Net::NBName->require();
    if ($EVAL_ERROR) {
        $self->{logger}->info(
            "Can't load Net::NBName, netbios can't be used"
        );
    }

    FusionInventory::Agent::SNMP::Live->require();
    if ($EVAL_ERROR) {
        $self->{logger}->info(
            "Can't load FusionInventory::Agent::SNMP::Live, snmp detection " .
            "can't be used"
        );
    } else {
        $snmp_credentials = $self->_getCredentials($options);
        $snmp_dictionary = $self->_getDictionary($options, $recipient, $pid);
        # abort immediatly if the dictionary isn't up to date
        if (!$snmp_dictionary) {
            $self->{logger}->debug("No dictionary available, exiting");
            return;
        }
    }

    # blocks list
    my @blocks = @{$options->{RANGEIP}};
    my $max_size = 0;
    foreach my $block (@blocks) {
        my $ip = Net::IP->new($block->{IPSTART} . '-' . $block->{IPEND});
        if (!$ip || $ip->binip() !~ /1/) {
            $self->{logger}->error(
                "IPv4 range not supported by Net::IP: ".
                $block->{IPSTART} . '-' . $block->{IPEND}
            );
            next;
        }
        $block->{ip} = $ip;

        my $size = $ip->size();
        $max_size = $size if $size >= $max_size;
    }

    # no need for more threads than addresses in any single block
    if ($max_threads > $max_size) {
        $max_threads = $max_size;
    }

    my $engine_class = $max_threads > 1 ?
        'FusionInventory::Agent::Task::NetDiscovery::Engine::Thread' :
        'FusionInventory::Agent::Task::NetDiscovery::Engine::NoThread';

    $engine_class->require();

    my $engine = $engine_class->new(
        logger           => $self->{logger},
        datadir          => $self->{datadir},
        nmap_parameters  => $nmap_parameters,
        snmp_credentials => $snmp_credentials,
        snmp_dictionary  => $snmp_dictionary,
        threads          => $max_threads,
        timeout          => $timeout,
    );

    # send initial message to the server
    $self->_sendMessage(
        $recipient,
        {
            AGENT => {
                START        => 1,
                AGENTVERSION => $FusionInventory::Agent::VERSION,
            },
            MODULEVERSION => $FusionInventory::Agent::VERSION,
            PROCESSNUMBER => $pid
        }
    );

    # proceed each given IP block
    foreach my $block (@blocks) {
        my @addresses;
        do {
            push @addresses, $block->{ip}->ip(),
        } while (++$block->{ip});
        $self->{logger}->debug(
            "scanning range: $block->{IPSTART}-$block->{IPEND}"
        );

        # send block size to the server
        $self->_sendMessage(
            $recipient,
            {
                AGENT => {
                    NBIP => scalar @addresses
                },
                PROCESSNUMBER => $pid
            }
        );

        my @results = $engine->scan(@addresses);

        foreach my $result (@results) {
            $result->{ENTITY} = $block->{ENTITY} if defined($block->{ENTITY});
            my $data = {
                DEVICE        => [$result],
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid,
            };
            $self->_sendMessage($recipient, $data);
        }
    }

    $engine->finish();

    # send final message to the server
    $self->_sendMessage(
        $recipient,
        {
            AGENT => {
                END => 1,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $pid
        }
    );
}

sub _getDictionary {
    my ($self, $options, $recipient, $pid) = @_;

    my $storage = $self->{controller}->getStorage();

    # use dictionary sent by the server, if available
    if ($options->{DICO}) {
        $self->{logger}->debug("New dictionary sent by the server");

        my $dictionary =
            FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
                string => $options->{DICO},
                hash   => $options->{DICOHASH}
            );

        $storage->save(
            name => 'dictionary',
            data => { dictionary => $dictionary }
        );

        return $dictionary;
    }

    # otherwise, retrieve last saved one
    $self->{logger}->debug("Retrieving stored dictionary");
    my $data = $storage->restore(name => 'dictionary');
    my $dictionary = $data->{dictionary};

    if (!$dictionary) {
        $self->{logger}->debug("Dictionary is missing, update request sent");
        $self->_sendUpdateMessage($recipient, $pid);
        return;
    }

    # check its status
    my $hash = $dictionary->getHash();
    if ($hash eq $options->{DICOHASH}) {
        return $dictionary;
    }

    $self->{logger}->debug("Dictionary is outdated, update request sent");
    $self->_sendUpdateMessage($recipient, $pid);
    return;
}

sub _sendUpdateMessage {
    my ($self, $recipient, $pid) = @_;

    $self->_sendMessage(
        $recipient,
        {
            AGENT => {
                END => '1'
            },
            MODULEVERSION => $FusionInventory::Agent::VERSION,
            PROCESSNUMBER => $pid,
            DICO          => "REQUEST",
        }
    );
}

sub _getCredentials {
    my ($self, $options) = @_;

    my @credentials;

    foreach my $credential (@{$options->{AUTHENTICATION}}) {
        if ($credential->{VERSION} eq '3') {
            # a user name is required
            next unless $credential->{USERNAME};
            # DES support is required
            next unless Crypt::DES->require();
        } else {
            next unless $credential->{COMMUNITY};
        }
        push @credentials, $credential;
    }

    return \@credentials;
}

sub _sendMessage {
    my ($self, $recipient, $content) = @_;

    my $message = FusionInventory::Agent::XML::Query->new(
        deviceid => $self->{deviceid},
        query    => 'NETDISCOVERY',
        content  => $content
    );

    $recipient->send(message => $message);
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery - Network discovery task

=head1 DESCRIPTION

This tasks scans the network to find connected devices, allowing:

=over

=item *

devices discovery within an IP range, through nmap, NetBios or SNMP

=item *

devices identification, through SNMP

=back

This task requires a GLPI server with FusionInventory plugin.

=head1 AUTHORS

Copyright (C) 2009 David Durieux
Copyright (C) 2010-2012 FusionInventory Team
