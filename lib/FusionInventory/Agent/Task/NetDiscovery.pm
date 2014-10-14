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
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::Recipient::Stdout;
use FusionInventory::Agent::Tools;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if (!$response) {
        $self->{logger}->debug("Task not compatible with a local controller");
        return;
    }

    my $options = $response->getOptionsInfoByName('NETDISCOVERY');
    if (!$options) {
        $self->{logger}->debug("Task not scheduled");
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
            my $newkey =
                $key eq 'AUTHPASSPHRASE' ? 'authpassword' :
                $key eq 'PRIVPASSPHRASE' ? 'privpassword' :
                                            lc($key)      ;
            $credential->{$newkey} = $authentication->{$key};
        }
        push @credentials, $credential;
    }

    return (
        pid         => $options->{PARAM}->[0]->{PID},
        threads     => $options->{PARAM}->[0]->{THREADS_DISCOVERY},
        timeout     => $options->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        blocks      => \@blocks
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->info("Running NetDiscovery task");

    my @blocks = @{$self->{config}->{blocks}};
    if (!@blocks) {
        $self->{logger}->error("no addresses block given, aborting");
        return;
    }
    $self->{logger}->debug(
        "got " . scalar @blocks . " address blocks to scan"
    );

    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Stdout->new();

    my $pid         = $self->{config}->{pid};

    # check discovery methods available
    my ($nmap_parameters, $snmp_credentials);

    if (canRun('nmap')) {
       my ($major, $minor) = getFirstMatch(
           command => 'nmap -V',
           pattern => qr/Nmap version (\d+)\.(\d+)/
       );
       $nmap_parameters = compareVersion($major, $minor, 5, 29) ?
           "-sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms" :
           "-sP --system-dns --max-retries 1 --max-rtt-timeout 1000ms"     ;
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
        $snmp_credentials = _filterCredentials($self->{config}->{credentials});
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
    my $threads = $self->{config}->{threads};
    if ($threads > $max_size) {
        $threads = $max_size;
    }

    my $engine_class = $threads > 1 ?
        'FusionInventory::Agent::Task::NetDiscovery::Engine::Thread' :
        'FusionInventory::Agent::Task::NetDiscovery::Engine::NoThread';

    $engine_class->require();

    my $engine = $engine_class->new(
        logger           => $self->{logger},
        datadir          => $self->{config}->{datadir},
        nmap_parameters  => $nmap_parameters,
        snmp_credentials => $snmp_credentials,
        threads          => $threads,
        timeout          => $self->{config}->{timeout}
    );

    my $deviceid = $self->{config}->{deviceid};

    # send initial message to the server
    _sendStartMessage($recipient, $pid, $deviceid);

    # proceed each given IP block
    foreach my $block (@blocks) {
        my @addresses;
        do {
            push @addresses, $block->{ip}->ip(),
        } while (++$block->{ip});
        $self->{logger}->debug("scanning block $block->{spec}");

        # send block size to the server
        _sendCountMessage($recipient, $pid, $deviceid, scalar @addresses, $block->{spec});

        my @results = $engine->scan(@addresses);

        my $count = 1;
        foreach my $result (@results) {
            $result->{ENTITY} = $block->{ENTITY} if defined($block->{ENTITY});
            my $message = FusionInventory::Agent::Message::Outbound->new(
                query    => 'NETDISCOVERY',
                deviceid => $deviceid,
                content  => {
                    DEVICE        => [$result],
                    MODULEVERSION => $VERSION,
                    PROCESSNUMBER => $pid,
                }
            );
            $recipient->send(
                message  => $message,
                filename => sprintf('discovery_%s.xml', $count++),
            );
        }
    }

    $engine->finish();

    # send final message to the server
    _sendStopMessage($recipient, $pid, $deviceid);
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

sub _sendStartMessage {
    my ($recipient, $pid, $deviceid) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        query    => 'NETDISCOVERY',
        deviceid => $deviceid,
        content  => {
            AGENT => {
                START        => 1,
                AGENTVERSION => $FusionInventory::Agent::VERSION,
            },
            MODULEVERSION => $FusionInventory::Agent::VERSION,
            PROCESSNUMBER => $pid
        },
    );

    $recipient->send(
        message => $message, control => 1, filename => 'discovery_start.xml'
    );
}

sub _sendStopMessage {
    my ($recipient, $pid, $deviceid) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        query    => 'NETDISCOVERY',
        deviceid => $deviceid,
        content  => {
            AGENT => {
                END => 1,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $pid
        }
    );

    $recipient->send(
        message => $message, control => 1, filename => 'discovery_stop.xml'
    );
}

sub _sendCountMessage {
    my ($recipient, $pid, $deviceid, $count, $spec) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        query    => 'NETDISCOVERY',
        deviceid => $deviceid,
        content  => {
            AGENT => {
                NBIP => $count
            },
            PROCESSNUMBER => $pid
        },
    );

    my $filename = sprintf('discovery_%s_size.xml', $spec);
    $filename =~ s{/}{_}g;

    $recipient->send(
        message => $message, control => 1, filename => $filename
    );
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
