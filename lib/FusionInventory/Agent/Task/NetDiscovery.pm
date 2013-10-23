package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use constant DEVICE_PER_MESSAGE => 4;

use English qw(-no_match_vars);
use Net::IP;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Broker::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::XML::Query;

our $VERSION = $FusionInventory::Agent::VERSION;

sub isEnabled {
    my ($self, %params) = @_;

    return unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

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

    # use given output broker, otherwise assume the target is a GLPI server
    my $broker =
        $params{broker} ||
        FusionInventory::Agent::Broker::Server->new(
            target       => $self->{target}->getUrl(),
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
        $snmp_dictionary = $self->_getDictionary($options, $broker, $pid);
        # abort immediatly if the dictionary isn't up to date
        return unless $snmp_dictionary;
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
        $broker,
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
            $broker,
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
            $self->_sendMessage($broker, $data);
        }
    }

    $engine->finish();

    # send final message to the server
    $self->_sendMessage(
        $broker,
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
    my ($self, $options, $broker, $pid) = @_;

    my ($dictionary, $hash);
    my $storage = $self->{target}->getStorage();

    if ($options->{DICO}) {
        # new dictionary sent by the server, load it and save it for next run
        $dictionary =
            FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
                string => $options->{DICO}
            );
        $hash = $options->{DICOHASH};

        $storage->save(
            name => 'dictionary',
            data => {
                dictionary => $dictionary,
                hash       => $hash
            }
        );
    } else {
        # no dictionary in server message, retrieve last saved one
        my $data = $storage->restore(name => 'dictionary');
        $dictionary = $data->{dictionary};
        $hash       = $data->{hash};
    }

    if ($options->{DICOHASH}) {
        if ($hash) {
            if ($hash eq $options->{DICOHASH}) {
                $self->{logger}->debug("Dictionary is up to date.");
            } else {
                $self->_sendUpdateMessage($broker, $pid);
                $self->{logger}->debug(
                    "Dictionary is outdated, update request sent, exiting"
                );
                return;
            }
        } else {
            $self->_sendUpdateMessage($broker, $pid);
            $self->{logger}->debug(
                "No dictionary, update request sent, exiting"
            );
            return;
        }
    }

    $self->{logger}->debug("Dictionary loaded.");

    return $dictionary;
}

sub _sendUpdateMessage {
    my ($self, $broker, $pid) = @_;

    $self->_sendMessage(
        $broker,
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
    my ($self, $broker, $content) = @_;

    my $message = FusionInventory::Agent::XML::Query->new(
        deviceid => $self->{deviceid},
        query    => 'NETDISCOVERY',
        content  => $content
    );

    $broker->send(message => $message);
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
