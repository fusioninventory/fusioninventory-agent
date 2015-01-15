package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use Net::IP;
use Parallel::ForkManager;
use UNIVERSAL::require;
use XML::TreePP;

use FusionInventory::Agent;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Hardware;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $options = $params{spec}->{config};

    my @credentials;
    foreach my $item (@{$options->{AUTHENTICATION}}) {
        my $credentials;
        foreach my $key (keys %$item) {
            next unless $item->{$key};
            my $newkey =
                $key eq 'AUTHPASSPHRASE' ? 'authpassword' :
                $key eq 'PRIVPASSPHRASE' ? 'privpassword' :
                                            lc($key)      ;
            $credentials->{$newkey} = $item->{$key};
        }
        push @credentials, $credentials;
    }

    my @blocks;
    foreach my $item (@{$options->{RANGEIP}}) {
        push @blocks, {
            id     => $item->{ID},
            spec   => $item->{IPSTART} . '-' . $item->{IPEND},
            entity => $item->{ENTITY}
        };
    }

    return (
        pid         => $options->{PARAM}->[0]->{PID},
        workers     => $options->{PARAM}->[0]->{THREADS_DISCOVERY},
        timeout     => $options->{PARAM}->[0]->{TIMEOUT},
        credentials => \@credentials,
        blocks      => \@blocks
    );
}

sub run {
    my ($self, %params) = @_;

    my $target = $params{target}
        or die "no target provided, aborting";
    my @blocks = @{$self->{config}->{blocks}}
        or die "no blocks provided, aborting";
    my $snmp_credentials =
        _filterCredentials($self->{config}->{snmp_credentials});
    my $max_workers = $self->{config}->{workers} || 0;
    my $pid         = $self->{config}->{pid}     || 1;
    my $timeout     = $self->{config}->{timeout} || 1;

    # check discovery methods available
    my $nmap_parameters;

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
    }

    # set internal state
    $self->{pid} = $pid;
    $self->{target} = $target;

    # send initial message to the server
    $self->_sendStartMessage();

    # process each address block
    foreach my $block (@blocks) {
        my $object = Net::IP->new($block->{spec});
        if (!$object || $object->{binip} !~ /1/) {
            $self->{logger}->error(
                "invalid IP block specification: $block->{spec}"
            );
            next;
        }

        $self->{logger}->debug("scanning block $block->{spec}");

        my @addresses;
        do {
            push @addresses, $object->ip();
        } while (++$object);
        my $size = scalar @addresses;

        # send block size to the server
        $self->_sendBlockMessage($size);

        # no need for more workers than IP address to process
        my $workers_count = $max_workers > $size ? $size : $max_workers;
        my $manager = Parallel::ForkManager->new($workers_count);

        foreach my $address (@addresses) {
            $manager->start() and next;

            my $result = $self->_scanAddress(
                ip               => $address,
                timeout          => $timeout,
                nmap_parameters  => $nmap_parameters,
                snmp_credentials => $snmp_credentials,
            );

            if ($result) {
                $result->{entity} = $block->{entity}
                    if defined($block->{entity});
                $self->_sendResultMessage($result, $address);
            }

            $manager->finish();
        }

        $manager->wait_all_children();
    }

    # send final message to the server
    $self->_sendStopMessage();

    delete $self->{pid};
    delete $self->{target};
}

sub abort {
    my ($self) = @_;

    $self->_sendStopMessage() if $self->{pid};
    $self->SUPER::abort();
}

sub _filterCredentials {
    my ($credentials) = @_;

    return [ grep { _validCredentials($_) } @$credentials ];
}

sub _validCredentials {
    my ($credentials) = @_;

    if ($credentials->{version} eq '3') {
        # a user name is required
        return 0 unless $credentials->{username};
        # DES support is required
        return 0 unless Crypt::DES->require();
    } else {
        return 0 unless $credentials->{community};
    }

    return 1;
}

sub _scanAddress {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    $logger->debug(
        '%sscanning %s',
        $self->{config}->{workers} ? "[worker $PID] " : '',
        $params{ip}
    );

    my %device = (
        $params{nmap_parameters} ? $self->_scanAddressByNmap(%params)    : (),
        $INC{'Net/NBName.pm'}    ? $self->_scanAddressByNetbios(%params) : (),
        $INC{'Net/SNMP.pm'}      ? $self->_scanAddressBySNMP(%params)    : ()
    );

    # don't report anything without a minimal amount of information
    return unless
        $device{MAC}          ||
        $device{SNMPHOSTNAME} ||
        $device{DNSHOSTNAME}  ||
        $device{NETBIOSNAME};

    $device{IP} = $params{ip};

    if ($device{MAC}) {
        $device{MAC} =~ tr/A-F/a-f/;
    }

    $device{origin} = $params{IP};

    return \%device;
}

sub _scanAddressByNmap {
    my ($self, %params) = @_;

    my $device = _parseNmap(
        command => "nmap $params{nmap_parameters} $params{ip} -oX -"
    );

    $self->{logger}->debug(
        '%sscanning %s with nmap: %s',
        $self->{config}->{workers} ? "[worker $PID] " : '',
        $params{ip},
        $device ? 'success' : 'no result'
    );

    return $device ? %$device : ();
}

sub _scanAddressByNetbios {
    my ($self, %params) = @_;

    my $nb = Net::NBName->new();

    my $ns = $nb->node_status($params{ip});

    $self->{logger}->debug(
        '%sscanning %s with netbios: %s',
        $self->{config}->{workers} ? "[worker $PID] " : '',
        $params{ip},
        $ns ? 'success' : 'no result'
    );
    return unless $ns;

    my %device;
    foreach my $rr ($ns->names()) {
        my $suffix = $rr->suffix();
        my $G      = $rr->G();
        my $name   = $rr->name();
        if ($suffix == 0 && $G eq 'GROUP') {
            $device{WORKGROUP} = getSanitizedString($name);
        }
        if ($suffix == 3 && $G eq 'UNIQUE') {
            $device{USERSESSION} = getSanitizedString($name);
        }
        if ($suffix == 0 && $G eq 'UNIQUE') {
            $device{NETBIOSNAME} = getSanitizedString($name)
                unless $name =~ /^IS~/;
        }
    }

    $device{MAC} = $ns->mac_address();
    $device{MAC} =~ tr/-/:/;

    return %device;
}

sub _scanAddressBySNMP {
    my ($self, %params) = @_;

    foreach my $credential (@{$params{snmp_credentials}}) {
        my %device = $self->_scanAddressBySNMPReal(
            ip         => $params{ip},
            timeout    => $params{timeout},
            credential => $credential
        );

        # no result means either no host, no response, or invalid credentials
        $self->{logger}->debug(
            '%sscanning %s with SNMP, credentials %d: %s',
            $self->{config}->{workers} ? "[worker $PID] " : '',
            $params{ip},
            $credential->{id},
            %device ? 'success' : 'no result'
        );

        if (%device) {
            $device{AUTHSNMP} = $credential->{id};
            return %device;
        }
    }

    return;
}

sub _scanAddressBySNMPReal {
    my ($self, %params) = @_;

    my $snmp;
    eval {
        $snmp = FusionInventory::Agent::SNMP::Live->new(
            version      => $params{credential}->{version},
            hostname     => $params{ip},
            timeout      => $params{timeout},
            community    => $params{credential}->{community},
            username     => $params{credential}->{username},
            authpassword => $params{credential}->{authpassphrase},
            authprotocol => $params{credential}->{authprotocol},
            privpassword => $params{credential}->{privpassphrase},
            privprotocol => $params{credential}->{privprotocol},
        );
    };
    # an exception here just means no device,  or wrong credentials
    return if $EVAL_ERROR;

    my $info = getDeviceInfo(
        snmp    => $snmp,
        datadir => $self->{config}->{datadir},
        logger  => $self->{logger},
    );
    return unless $info;

    return %$info;
}

sub _parseNmap {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode
    my $tpp  = XML::TreePP->new(force_array => '*');
    my $tree = $tpp->parse(<$handle>);
    close $handle;
    return unless $tree;

    my $result;

    foreach my $host (@{$tree->{nmaprun}[0]{host}}) {
        foreach my $address (@{$host->{address}}) {
            next unless $address->{'-addrtype'} eq 'mac';
            $result->{MAC}           = $address->{'-addr'};
            $result->{NETPORTVENDOR} = $address->{'-vendor'};
            last;
        }
        foreach my $hostname (@{$host->{hostnames}}) {
            my $name = eval {$hostname->{hostname}[0]{'-name'}};
            next unless $name;
            $result->{DNSHOSTNAME} = $name;
        }
    }

    return $result;
}

sub _sendStartMessage {
    my ($self) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'NETDISCOVERY',
        content  => {
            AGENT => {
                START        => 1,
                AGENTVERSION => $FusionInventory::Agent::VERSION,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(message => $message);
}

sub _sendStopMessage {
    my ($self) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'NETDISCOVERY',
        content  => {
            AGENT => {
                END => 1,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(message => $message);
}

sub _sendBlockMessage {
    my ($self, $count) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'NETDISCOVERY',
        content  => {
            AGENT => {
                NBIP => $count
            },
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(message => $message);
}

sub _sendResultMessage {
    my ($self, $result, $address) = @_;

    my $message = FusionInventory::Agent::Message::Outbound->new(
        deviceid => $self->{config}->{deviceid},
        query    => 'NETDISCOVERY',
        content  => {
            DEVICE        => [$result],
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $self->{pid}
        }
    );

    $self->{target}->send(
        message  => $message,
        filename => sprintf('netdiscovery_%s.xml', $address),
    );
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery - Net discovery support

=head1 DESCRIPTION

This module allows the FusionInventory agent to perform connected devices
discovery through SNMP, NetBios, and ICMP protocols.
