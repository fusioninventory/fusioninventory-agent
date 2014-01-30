package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use constant DEVICE_PER_MESSAGE => 4;

use English qw(-no_match_vars);
use Net::IP;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Recipient::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::XML::Query;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if (!$response) {
        $self->{logger}->info("Task not compatible");
        return;
    }

    my $options = $response->getOptionsInfoByName('NETDISCOVERY');
    if (!$options) {
        $self->{logger}->info("Task not scheduled");
        return;
    }
    return unless $options;

    # blocks list
    my @blocks;
    foreach my $range (@{$options->{RANGEIP}}) {
        push @blocks, {
            id     => $range->{ID},
            spec   => $range->{IPSTART} . '-' . $range->{IPEND},
            entity => $range->{ENTITY}
        };
    }

    my @credentials;
    foreach my $authentication (@{$options->{AUTHENTICATION}}) {
        my $credential;
        foreach my $key (keys %$authentication) {
            $credential->{lc($key)} = $authentication->{$key};
        }
        push @credentials, $credential;
    }

    # dictionary
    my $dictionary = $self->_getDictionary(
        $options,
        $self->{controller}->getStorage()
    );

    if (!$dictionary) {
        $self->{logger}->debug(
            "No dictionary available, sending update message and exiting"
        );
        my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
        );

        my $message = FusionInventory::Agent::XML::Query->new(
            deviceid => $self->{params}->{deviceid},
            query    => 'NETDISCOVERY',
            content  => {
                AGENT => {
                    END => '1'
                },
                MODULEVERSION => $FusionInventory::Agent::VERSION,
                PROCESSNUMBER => $options->{PARAM}->[0]->{PID},
                DICO          => "REQUEST",
            }
        );

        $client->send(
            url     => $self->{controller}->getUrl(),
            message => $message
        );

        return;
    }

    return (
        pid         => $options->{PARAM}->[0]->{PID},
        threads     => $options->{PARAM}->[0]->{THREADS_DISCOVERY},
        timeout     => $options->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        dictionary  => $dictionary,
        blocks      => \@blocks
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("running NetDiscovery task");

    my @blocks = @{$self->{params}->{blocks}};
    if (!@blocks) {
        $self->{logger}->error("no addresses block given, aborting");
        return;
    }

    $self->{logger}->info("got @blocks address blocks to scan");

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

    my $pid         = $self->{params}->{pid};

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
        $snmp_credentials = _filterCredentials($self->{params}->{credentials});
        $snmp_dictionary = $self->{params}->{dictionary};
    }

    # blocks list
    my $max_size = 0;
    foreach my $block (@blocks) {
        my $ip = Net::IP->new($block->{spec});
        if (!$ip || $ip->binip() !~ /1/) {
            $self->{logger}->error(
                "IPv4 specification not supported by Net::IP: $block->{spec}"
            );
            next;
        }
        $block->{ip} = $ip;

        my $size = $ip->size();
        $max_size = $size if $size >= $max_size;
    }

    # no need for more threads than addresses in any single block
    my $threads = $self->{params}->{threads};
    if ($threads > $max_size) {
        $threads = $max_size;
    }

    my $engine_class = $threads > 1 ?
        'FusionInventory::Agent::Task::NetDiscovery::Engine::Thread' :
        'FusionInventory::Agent::Task::NetDiscovery::Engine::NoThread';

    $engine_class->require();

    my $engine = $engine_class->new(
        logger           => $self->{logger},
        datadir          => $self->{params}->{datadir},
        nmap_parameters  => $nmap_parameters,
        snmp_credentials => $snmp_credentials,
        snmp_dictionary  => $snmp_dictionary,
        threads          => $threads,
        timeout          => $self->{params}->{timeout}
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
        $self->{logger}->debug("scanning block $block->{spec}");

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
    my ($self, $options, $storage) = @_;

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
        $self->{logger}->debug("Dictionary is missing");
        return;
    }

    # check its status
    my $hash = $dictionary->getHash();
    if ($hash ne $options->{DICOHASH}) {
        $self->{logger}->debug("Dictionary is outdated");
        return;
    }

    return $dictionary;
}

sub _filterCredentials {
    my ($credentials) = @_;

    return unless $credentials;

    # filter irrelevant credentials
    return [ grep { _isValidCredential($_) } @{$credentials} ];
}

sub _isValidCredential {
    my ($credential) = @_;

    return unless $credential->{version};

    if ($credential->{version} eq '3') {
        # a user name is required
        return unless $credential->{username};
        # DES support is required
        return unless Crypt::DES->require();
    } else {
        return unless $credential->{community};
    }

    return 1;
}

sub _sendMessage {
    my ($self, $recipient, $content) = @_;

    my $message = FusionInventory::Agent::XML::Query->new(
        deviceid => $self->{params}->{deviceid},
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
