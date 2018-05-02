package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use threads;
use parent 'FusionInventory::Agent::Task';

use constant DEVICE_PER_MESSAGE => 4;

use English qw(-no_match_vars);
use Net::IP;
use Time::localtime;
use Time::HiRes qw(usleep);
use Thread::Queue v2.01;
use UNIVERSAL::require;
use XML::TreePP;

use FusionInventory::Agent::Version;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Expiration;
use FusionInventory::Agent::XML::Query;

use FusionInventory::Agent::Task::NetDiscovery::Version;

our $VERSION = FusionInventory::Agent::Task::NetDiscovery::Version::VERSION;

sub isEnabled {
    my ($self, $response) = @_;

    if (!$self->{target}->isType('server')) {
        $self->{logger}->debug("NetDiscovery task not compatible with local target");
        return;
    }

    my @options = $response->getOptionsInfoByName('NETDISCOVERY');
    if (!@options) {
        $self->{logger}->debug("NetDiscovery task execution not requested");
        return;
    }

    my @jobs;
    foreach my $option (@options) {
        if (!$option->{RANGEIP}) {
            $self->{logger}->error("invalid job: no IP range defined");
            next;
        }

        my @ranges;
        foreach my $range (@{$option->{RANGEIP}}) {
            if (!$range->{IPSTART}) {
                $self->{logger}->error(
                    "invalid range: no first address defined"
                );
                next;
            }
            if (!$range->{IPEND}) {
                $self->{logger}->error(
                    "invalid range: no last address defined"
                );
                next;
            }
            push @ranges, $range;
        }

        if (!@ranges) {
            $self->{logger}->error("invalid job: no valid IP range defined");
            next;
        }

        push @jobs, {
            params      => $option->{PARAM}->[0],
            credentials => $option->{AUTHENTICATION},
            ranges      => \@ranges,
        };
    }

    if (!@jobs) {
        $self->{logger}->error("no valid job found, aborting");
        return;
    }

    $self->{jobs} = \@jobs;

    return 1;
}

sub run {
    my ($self, %params) = @_;

    # task-specific client, if needed
    $self->{client} = FusionInventory::Agent::HTTP::Client::OCS->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
        no_compress  => $params{no_compress},
    ) if !$self->{client};

    # check discovery methods available
    my $nmap_parameters;

    if (canRun('nmap')) {
       my ($major, $minor) = getFirstMatch(
           command => 'nmap -V',
           pattern => qr/Nmap version (\d+)\.(\d+)/
       );
       $nmap_parameters = compareVersion($major, $minor, 5, 29) ?
           "-sP -PE -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms" :
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

    foreach my $job (@{$self->{jobs}}) {
        my $pid         = $job->{params}->{PID};
        my $max_threads = $job->{params}->{THREADS_DISCOVERY};
        my $timeout     = $job->{params}->{TIMEOUT};

        # SNMP credentials
        my $snmp_credentials = _getValidCredentials($job->{credentials});

        # set internal state
        $self->{pid} = $pid;

        # send initial message to the server
        $self->_sendStartMessage();

        my ($debug_sent_count, $threads_count, $started_count) = ( 0, 0, 0 );
        my %running_threads = ();

        # process each address block
        foreach my $range (@{$job->{ranges}}) {
            my $ports = $self->_getSNMPPorts($range->{PORT});
            my $proto = $self->_getSNMPProtocols($range->{PROTOCOL});
            my $block = Net::IP->new(
                $range->{IPSTART} . '-' . $range->{IPEND}
            );
            if (!$block || $block->{binip} !~ /1/) {
                $self->{logger}->error(
                    "IPv4 range not supported by Net::IP: ".
                    $range->{IPSTART} . '-' . $range->{IPEND}
                );
                next;
            }

            $self->{logger}->debug(
                "scanning block $range->{IPSTART}-$range->{IPEND}"
            );

            # initialize FIFOs
            my $addresses = Thread::Queue->new();
            my $results   = Thread::Queue->new();

            do {
                $addresses->enqueue($block->ip()),
            } while (++$block);
            my $size = $addresses->pending();

            # send block size to the server
            $self->_sendBlockMessage($size);

            # no need for more threads than addresses to scan in this range
            my $threads_count = $max_threads > $size ? $size : $max_threads;

            # Define a realistic block scan expiration : at least one minute by address
            setExpirationTime(
                timeout => $size * (!$timeout || $timeout < 60 ? 60 : $timeout)
            );
            my $expiration = getExpirationTime();

            my $sub = sub {
                my $id = threads->tid();
                $self->{logger}->debug("[thread $id] creation");

                # run as long as they are addresses to process
                while (my $address = $addresses->dequeue_nb()) {

                    my $result = $self->_scanAddress(
                        ip               => $address,
                        timeout          => $timeout,
                        nmap_parameters  => $nmap_parameters,
                        snmp_credentials => $snmp_credentials,
                        snmp_ports       => $ports,
                        snmp_domains     => $proto,
                    );

                    $results->enqueue($result) if $result;
                }

                $self->{logger}->debug("[thread $id] termination");
            };

            $self->{logger}->debug("creating $threads_count worker threads");
            for (my $i = 0; $i < $threads_count; $i++) {
                my $newthread = threads->create($sub);
                # Keep known created threads in a hash
                $running_threads{$newthread->tid()} = $newthread ;
                usleep(50000) until ($newthread->is_running() || $newthread->is_joinable());
            }

            # Check really started threads number vs really running ones
            my @really_running  = map { $_->tid() } threads->list(threads::running);
            my @started_threads = keys(%running_threads);
            unless (@really_running == $threads_count && keys(%running_threads) == $threads_count) {
                $self->{logger}->debug(scalar(@really_running)." really running: [@really_running]");
                $self->{logger}->debug(scalar(@started_threads)." started: [@started_threads]");
            }
            $started_count += @started_threads ;

            # as long as some of our threads are still running...
            while (keys(%running_threads)) {

                # send available results on the fly
                while (my $result = $results->dequeue_nb()) {
                    $result->{ENTITY} = $range->{ENTITY}
                        if defined($range->{ENTITY});
                    $self->_sendResultMessage($result);
                }

                if ($expiration && time > $expiration) {
                    $self->{logger}->warning("Aborting block scan as it reached expiration time");
                    # detach all our running worker
                    foreach my $tid (keys(%running_threads)) {
                        $running_threads{$tid}->detach()
                            if $running_threads{$tid}->is_running();
                        delete $running_threads{$tid};
                    }
                    last;
                }

                # wait for a little
                usleep(50000);

                # List our created and possibly running threads in a list to check
                my %running_threads_checklist =
                    map { $_ => 0 } keys(%running_threads);

                foreach my $running (threads->list(threads::running)) {
                    my $tid = $running->tid();
                    # Skip if this running thread tid is not is our started list
                    next unless exists($running_threads{$tid});

                    # Check a thread is still running
                    $running_threads_checklist{$tid} = 1 ;
                }

                # Clean our started list from thread tid that don't run anymore
                foreach my $tid (keys(%running_threads_checklist)) {
                    delete $running_threads{$tid}
                        unless $running_threads_checklist{$tid};
                }
            }

            # Reset expiration
            setExpirationTime();

            # purge remaning results
            while (my $result = $results->dequeue_nb()) {
                $result->{ENTITY} = $range->{ENTITY}
                    if defined($range->{ENTITY});
                $self->_sendResultMessage($result);
            }

        }

        # send final message to the server before cleaning threads
        $self->_sendStopMessage();

        if ($started_count) {
            $self->{logger}->debug("cleaning $started_count worker threads");
            $_->join() foreach threads->list(threads::joinable);
        }

        # send final message to the server
        $self->_sendStopMessage();
    }
}

sub abort {
    my ($self) = @_;

    $self->_sendStopMessage() if $self->{pid};
    $self->SUPER::abort();
}

sub _getValidCredentials {
    my ($credentials) = @_;

    my @credentials;

    foreach my $credential (@{$credentials}) {
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
    my ($self, $content) = @_;

    my $message = FusionInventory::Agent::XML::Query->new(
        deviceid => $self->{deviceid} || 'foo',
        query    => 'NETDISCOVERY',
        content  => $content
    );

    $self->{client}->send(
        url     => $self->{target}->getUrl(),
        message => $message
    );
}

sub _scanAddress {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();
    $logger->debug("[thread $id] scanning $params{ip}:");

    my %device = (
        $INC{'Net/SNMP.pm'}      ? $self->_scanAddressBySNMP(%params)    : (),
        $INC{'Net/NBName.pm'}    ? $self->_scanAddressByNetbios(%params) : (),
        $params{nmap_parameters} ? $self->_scanAddressByNmap(%params)    : ()
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

    return \%device;
}

sub _scanAddressByNmap {
    my ($self, %params) = @_;

    my $device = _parseNmap(
        ip      => $params{ip},
        command => "nmap $params{nmap_parameters} $params{ip} -oX -"
    );

    $self->{logger}->debug(
        sprintf "[thread %d] - scanning %s with nmap: %s",
        threads->tid(),
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
        sprintf "[thread %d] - scanning %s with netbios: %s",
        threads->tid(),
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

    my $tries = [];
    if ($params{snmp_ports} && @{$params{snmp_ports}}) {
        foreach my $port (@{$params{snmp_ports}}) {
            my @cases = map { { port => $port, credential => $_ } } @{$params{snmp_credentials}};
            push @{$tries}, @cases;
        }
    } else {
        @{$tries} = map { { credential => $_ } } @{$params{snmp_credentials}};
    }
    if ($params{snmp_domains} && @{$params{snmp_domains}}) {
        my @domtries = ();
        foreach my $domain (@{$params{snmp_domains}}) {
            my @cases = map { { %{$_}, domain => $domain } } @{$tries};
            push @domtries, @cases;
        }
        $tries = \@domtries;
    }

    foreach my $try (@{$tries}) {
        my $credential = $try->{credential};
        my $device = $self->_scanAddressBySNMPReal(
            ip         => $params{ip},
            port       => $try->{port},
            domain     => $try->{domain},
            timeout    => $params{timeout},
            credential => $credential
        );

        # no result means either no host, no response, or invalid credentials
        $self->{logger}->debug(
            sprintf "[thread %d] - scanning %s%s with SNMP%s, credentials %d: %s",
            threads->tid(),
            $params{ip},
            $try->{port}   ? ':'.$try->{port}   : '',
            $try->{domain} ? ' '.$try->{domain} : '',
            $credential->{ID},
            ref $device eq 'HASH' ? 'success' :
                $device ? "no result, $device" : 'no result'
        );

        if (ref $device eq 'HASH') {
            $device->{AUTHSNMP} = $credential->{ID};
            return %{$device};
        }
    }

    return;
}

sub _scanAddressBySNMPReal {
    my ($self, %params) = @_;

    my $snmp;
    eval {
        $snmp = FusionInventory::Agent::SNMP::Live->new(
            version      => $params{credential}->{VERSION},
            hostname     => $params{ip},
            port         => $params{port},
            domain       => $params{domain},
            timeout      => $params{timeout} || 1,
            community    => $params{credential}->{COMMUNITY},
            username     => $params{credential}->{USERNAME},
            authpassword => $params{credential}->{AUTHPASSPHRASE},
            authprotocol => $params{credential}->{AUTHPROTOCOL},
            privpassword => $params{credential}->{PRIVPASSPHRASE},
            privprotocol => $params{credential}->{PRIVPROTOCOL},
        );
    };

    # an exception here just means no device or wrong credentials
    return $EVAL_ERROR if $EVAL_ERROR;

    my $info = getDeviceInfo(
        snmp    => $snmp,
        datadir => $self->{datadir},
        logger  => $self->{logger},
    );
    return unless $info;

    return $info;
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
        # Verify nmap returned host is up, and than use ip as default hostname
        foreach my $status (@{$host->{status}}) {
            next unless $status->{'-state'} eq 'up';
            $result = { DNSHOSTNAME => $params{ip} };
            last;
        }
        next unless $result;
        foreach my $address (@{$host->{address}}) {
            next unless $address->{'-addrtype'} eq 'mac';
            $result->{MAC}           = $address->{'-addr'};
            $result->{NETPORTVENDOR} = $address->{'-vendor'};
            # We can delete default DNSHOSTNAME when a MAC is found
            delete $result->{DNSHOSTNAME};
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

    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::Version::VERSION,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _sendStopMessage {
    my ($self) = @_;

    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _sendBlockMessage {
    my ($self, $count) = @_;

    $self->_sendMessage({
        AGENT => {
            NBIP => $count
        },
        PROCESSNUMBER => $self->{pid}
    });
}

sub _sendResultMessage {
    my ($self, $result) = @_;

    $self->_sendMessage({
        DEVICE        => [$result],
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $self->{pid}
    });
}

sub _getSNMPPorts {
    my ($self, $ports) = @_;

    return unless $ports;

    # Given ports can be an array of strings or just a string and each string
    # can be a comma separated list of ports
    my @given_ports = map { split(/\s*,\s*/, $_) }
        ref($ports) eq 'ARRAY' ? @{$ports} : ($ports) ;

    # Be sure to only keep valid and uniq ports
    my %ports = map { $_ => 1 } grep { $_ && $_ > 0 && $_ < 65536 } @given_ports;

    return [ sort keys %ports ];
}

sub _getSNMPProtocols {
    my ($self, $protocols) = @_;

    return unless $protocols;

    # Supported protocols can be used as '-domain' option for Net::SNMP session
    my @supported_protocols = (
        'udp/ipv4',
        'udp/ipv6',
        'tcp/ipv4',
        'tcp/ipv6'
    );

    # Given protocols can be an array of strings or just a string and each string
    # can be a comma separated list of protocols
    my @given_protocols = map { split(/\s*,\s*/, $_) }
        ref($protocols) eq 'ARRAY' ? @{$protocols} : ($protocols) ;

    my @protocols = ();
    my %protocols = map { lc($_) => 1 } grep { $_ } @given_protocols;

    # Manage to list and filter protocols to use in @supported_protocols order
    foreach my $proto (@supported_protocols) {
        if ($protocols{$proto}) {
            push @protocols, $proto;
        }
    }

    return \@protocols;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery - Net discovery support for FusionInventory Agent

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
