package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use constant ADDRESS_PER_THREAD => 25;
use constant DEVICE_PER_MESSAGE => 4;

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use Data::Dumper;
use English qw(-no_match_vars);
use Net::IP;
use Time::localtime;
use UNIVERSAL::require;
use XML::TreePP;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Regexp;
use FusionInventory::Agent::Task::NetDiscovery::Dico;
use FusionInventory::Agent::XML::Query;

our $VERSION = '2.0';

my @dispatch_table = (
    {
        match    => qr/^\S+ Service Release/,
        module   => __PACKAGE__ . '::Manufacturer::Alcatel',
        function => 'getDescription'
    },
    {
        match    => qr/AXIS OfficeBasic Network Print Server/,
        module   => __PACKAGE__ . '::Manufacturer::Axis',
        function => 'getDescription'

    },
    {
        match    => qr/Linux/,
        module   => __PACKAGE__ . '::Manufacturer::Ddwrt',
        function => 'getDescription'
    },
    {
        match    => 'Ethernet Switch',
        module   => __PACKAGE__ . '::Manufacturer::Dell',
        function => 'getDescription'
    },
    {
        match    => qr/EPSON Built-in/,
        module   => __PACKAGE__ . '::Manufacturer::Epson',
        function => 'getDescriptionBuiltin'
    },
    {
        match    => qr/EPSON Internal 10Base-T/,
        module   => __PACKAGE__ . '::Manufacturer::Epson',
        function => 'getDescriptionInternal'
    },
    {
        match    => qr/HP ETHERNET MULTI-ENVIRONMENT/,
        module   => __PACKAGE__ . '::Manufacturer::HewlettPackard',
        function => 'getDescription'
    },
    {
        match    => qr/A SNMP proxy agent, EEPROM/,
        module   => __PACKAGE__ . '::Manufacturer::HewlettPackard',
        function => 'getDescription'
    },
    {
        match    => qr/,HP,JETDIRECT,J/,
        module   => __PACKAGE__ . '::Manufacturer::Kyocera',
        function => 'getDescriptionHP'
    },
    {
        match    => 'KYOCERA MITA Printing System',
        module   => __PACKAGE__ . '::Manufacturer::Kyocera',
        function => 'getDescriptionOther'
    },
    {
        match    => 'KYOCERA Printer I/F',
        module   => __PACKAGE__ . '::Manufacturer::Kyocera',
        function => 'getDescriptionOther'

    },
    {
        match    => 'SB-110',
        module   => __PACKAGE__ . '::Manufacturer::Kyocera',
        function => 'getDescriptionOther'

    },
        {
        match    => qr/RICOH NETWORK PRINTER/,
        module   => __PACKAGE__ . '::Manufacturer::Ricoh',
        function => 'getDescription'
    },
    {
        match   => qr/SAMSUNG NETWORK PRINTER,ROM/,
        module  => __PACKAGE__ . '::Manufacturer::Samsung',
        function => 'getDescription'
    },
    {
        match    => qr/Linux/,
        module   => __PACKAGE__ . '::Manufacturer::Wyse',
        function => 'getDescription'
    },
    {
        match    => qr/ZebraNet PrintServer/,
        module   => __PACKAGE__ . '::Manufacturer::Zebranet',
        function => 'getDescription'
    },
);

sub run {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $response = $self->{prologresp};
    if (!$response) {
        $self->{logger}->debug("No server response. Exiting...");
        return;
    }

    my $options = $response->getOptionsInfoByName('NETDISCOVERY');
    if (!$options) {
        $self->{logger}->debug(
            "No net discovery requested in the prolog, exiting"
        );
        return;
    }

    $self->{logger}->debug("FusionInventory NetDiscovery module ".$VERSION);

    my $params = $options->{PARAM}->[0];

    # take care of models dictionnary
    my $dico = $self->_getDictionnary($options, $params->{PID});
    return unless $dico;

    # check discovery methods available
    my $nmap_parameters;
    if (canRun('nmap')) {
       my ($major, $minor) = getFirstMatch(
           command => 'nmap -V',
           pattern => qr/Nmap version (\d+)\.(\d+)/
       );
       $nmap_parameters = compareVersion($major, $minor, 5, 29) ?
           "-sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms " :
           "-sP --system-dns --max-retries 1 --max-rtt-timeout 1000 "       ;
    }

    Net::NBName->require();
    if ($EVAL_ERROR) {
        $self->{logger}->error(
            "Can't load Net::NBName. Netbios detection can't be used!"
        );
    }

    FusionInventory::Agent::SNMP->require();
    if ($EVAL_ERROR) {
        $self->{logger}->error(
            "Can't load FusionInventory::Agent::SNMP. SNMP detection can't " .
            "be used!"
        );
    }

    # retrieve SNMP authentication credentials
    my $credentials = $options->{AUTHENTICATION};

    # convert given IP ranges into a flat list of IP addresses
    my @addresses;
    foreach my $range (@{$options->{RANGEIP}}) {
        next unless $range->{IPSTART};
        next unless $range->{IPEND};

        my $ip = Net::IP->new($range->{IPSTART}.' - '.$range->{IPEND});
        do {
            push @addresses, {
                IP     => $ip->ip(),
                ENTITY => $range->{ENTITY}
            };
        } while (++$ip);
    }

    # send initial message to the server
    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $params->{PID}
    });

    # create the required number of threads, sharing variables
    # for synchronisation
    my $maxIdx : shared = 0;
    my @addresses_block :shared;
    my @states : shared;

    for (my $i = 0; $i < $params->{THREADS_DISCOVERY}; $i++) {
        $states[$i] = START;

        threads->create(
            '_scanAddresses',
            $self,
            \$states[$i],
            \@addresses_block,
            $credentials,
            $nmap_parameters,
            $dico,
            $maxIdx
        )->detach();

        # sleep one second every 4 threads
        sleep 1 unless $i % 4;
    }

    # proceed the whole list of addresses block by block
    my $block_size = $params->{THREADS_DISCOVERY} * ADDRESS_PER_THREAD;
    while (@addresses) {
        # fetch a block of addresses from the global list
        @addresses_block =
            map { shared_clone($_) }
            splice @addresses, 0, $block_size;

        $self->{logger}->debug(
            "scanning block: $addresses_block[0]->{IP}, $addresses_block[-1]->{IP}"
        );

        # send block size to the server
        $self->_sendMessage({
            AGENT => {
                NBIP => scalar @addresses_block
            },
            PROCESSNUMBER => $params->{PID}
        });

        # set all threads in RUN state
        $_ = RUN foreach @states;

        # wait for all threads to reach STOP state
        while (any { $_ != STOP } @states) {
            sleep 1;
        }

        # send results to the server
        my $storage = $self->{target}->getStorage();
        foreach my $i (1 .. $maxIdx) {
            my $filename = sprintf('netdiscovery%02i', $i);
            my $data = {
                DEVICE        => $storage->restore(name => $filename),
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $params->{PID}
            };
            $self->_sendMessage($data);
            $storage->remove(name => $filename);
            sleep 1;
        }
    }

    # set all threads in EXIT state
    $_ = EXIT foreach @states;
    sleep 1;

    # send final message to the server
    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $params->{PID}
    });

}

sub _getDictionnary {
    my ($self, $options, $pid) = @_;

    my ($dictionnary, $hash);
    my $storage = $self->{target}->getStorage();

    if ($options->{DICO}) {
        # the server message contains a dictionnary, use it
        # and save it for later use
        $dictionnary = FusionInventory::Agent::Task::NetDiscovery::Dico->new(
            string => $options->{DICO}
        );
        $hash = $options->{DICOHASH};

        $storage->save(
            name => 'dictionnary',
            data => {
                dictionnary => $dictionnary,
                hash        => $hash
            }
        );
    } else {
        # no dictionnary in server message, retrieve last saved one
        my $data = $storage->restore(name => 'dictionnary');
        $dictionnary = $data->{dictionnary};
        $hash        = $data->{hash};
    }

    # fallback on builtin dictionnary
    if (!$dictionnary) {
        $dictionnary = FusionInventory::Agent::Task::NetDiscovery::Dico->new();
        $hash        = $dictionnary->getHash();
    }

    if ($options->{DICOHASH}) {
        if ($hash eq $options->{DICOHASH}) {
            $self->{logger}->debug("Dictionnary is up to date.");
        } else {
            # Send Dico request to plugin for next time :
            $self->_sendMessage({
                AGENT => {
                    END => '1'
                },
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid,
                DICO          => "REQUEST",
            });
            $self->{logger}->debug(
                "Dictionnary is too old ($hash vs $options->{DICOHASH}), exiting"
            );
            return;
        }
    }

    $self->{logger}->debug("Dictionnary loaded.");

    return $dictionnary;
}

sub _scanAddresses {
    my ($self, $state, $addresses, $credentials, $nmap_parameters, $dico, $maxIdx) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();
    
    $logger->debug("Thread $id created");

    # start: wait for state to change
    while ($$state == START) {
        sleep 1;
    }

    OUTER: while (1) {
        # run: process available addresses until exhaustion
        $$state = RUN;
        $logger->debug("Thread $id switched to RUN state");

        my @results;
        my $storage = $self->{target}->getStorage();

        INNER: while (1) {
            my $address;
            {
                lock $addresses;
                $address = shift @{$addresses};
            }
            last INNER unless $address;

            my $result = $self->_scanAddress(
                ip              => $address->{IP},
                entity          => $address->{ENTITY},
                credentials     => $credentials,
                nmap_parameters => $nmap_parameters,
                dico            => $dico
            );
            push @results, $result if $result;

            # save list each time the limit is reached
            if (@results % DEVICE_PER_MESSAGE == 0) {
                $maxIdx++;
                $storage->save(
                    name => sprintf('netdiscovery%02i', $maxIdx),
                    data => \@results,
                );
                undef @results;
            }
        }

        # save last devices
        if (@results) {
            $maxIdx++;
            $storage->save(
                name => sprintf('netdiscovery%02i', $maxIdx),
                data => \@results,
            );
        }

        # stop: wait for state to change
        $$state = STOP;
        $logger->debug("Thread $id switched to STOP state");
        while ($$state == STOP) {
            sleep 1;
        }

        # exit: exit thread
        last OUTER if $$state == EXIT;
    }

    $logger->debug("Thread $id deleted");
}

sub _sendMessage {
    my ($self, $content) = @_;

    my $message = FusionInventory::Agent::XML::Query->new(
        deviceid => $self->{deviceid},
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

    my %device = (
        $params{nmap_parameters} ? $self->_scanAddressByNmap(%params)    : (),
        $INC{'Net/NBName.pm'}    ? $self->_scanAddressByNetbios(%params) : (),
        $INC{'Net/SNMP.pm'}      ? $self->_scanAddressBySNMP(%params)    : ()
    );

    if ($device{MAC}) {
        $device{MAC} =~ tr/A-F/a-f/;
    }

    if ($device{MAC} || $device{DNSHOSTNAME} || $device{NETBIOSNAME}) {
        $device{IP}     = $params{ip};
        $device{ENTITY} = $params{entity};
        $self->{logger}->debug(
            "address $params{ip}: found device\n" . Dumper(\%device)
        );
    } else {
        $self->{logger}->debug("address $params{ip}: nothing found");
    }

    return \%device;
}

sub _scanAddressByNmap {
    my ($self, %params) = @_;

    $self->{logger}->debug("address $params{ip}: nmap scan");

    my $device = _parseNmap(
        command => "nmap $params{nmap_parameters} $params{ip} -oX -"
    );
    return $device ? %$device : ();
}

sub _scanAddressByNetbios {
    my ($self, %params) = @_;

    $self->{logger}->debug("address $params{ip}: Netbios scan");

    my $nb = Net::NBName->new();

    my $ns = $nb->node_status($params{ip});
    return unless $ns;

    my %device;
    foreach my $rr ($ns->names()) {
        if ($rr->suffix() == 0 && $rr->G() eq "GROUP") {
            $device{WORKGROUP} = getSanitizedString($rr->name);
        }
        if ($rr->suffix() == 3 && $rr->G() eq "UNIQUE") {
            $device{USERSESSION} = getSanitizedString($rr->name);
        }
        if ($rr->suffix() == 0 && $rr->G() eq "UNIQUE") {
            my $machine = $rr->name() unless $rr->name() =~ /^IS~/;
            $device{NETBIOSNAME} = getSanitizedString($machine);
        }
    }

    $device{MAC} = $ns->mac_address();
    $device{MAC} =~ tr/-/:/; 

    return %device;
}

sub _scanAddressBySNMP {
    my ($self, %params) = @_;

    $self->{logger}->debug("address $params{ip}: SNMP scan");

    my %device;
    foreach my $credential (@{$params{credentials}}) {

        my $snmp;
        eval {
            $snmp = FusionInventory::Agent::SNMP->new(
                version      => $credential->{VERSION},
                hostname     => $params{ip},
                community    => $credential->{COMMUNITY},
                username     => $credential->{USERNAME},
                authpassword => $credential->{AUTHPASSWORD},
                authprotocol => $credential->{AUTHPROTOCOL},
                privpassword => $credential->{PRIVPASSWORD},
                privprotocol => $credential->{PRIVPROTOCOL},
                translate    => 1,
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error(
                "Unable to create SNMP session for $params{ip}: $EVAL_ERROR"
            );
            next;
        }

        my $description = $snmp->get('1.3.6.1.2.1.1.1.0');
        return unless $description;

        foreach my $entry (@dispatch_table) {
            if (ref $entry->{match} eq 'Regexp') {
                next unless $description =~ $entry->{match};
            } else {
                next unless $description eq $entry->{match};
            }

            $entry->{module}->require();
            if ($EVAL_ERROR) {
                $self->{logger}->debug(
                    "Failed to load $entry->{module}: $EVAL_ERROR"
                );
                last;
            }

            no strict 'refs'; ## no critic
            $description = &{$entry->{module} . '::' . $entry->{function}}(
                $snmp
            );

            last;
        }

        $device{DESCRIPTION} = $description;

        # get model matching description from dictionnary
        my $model = $params{dico}->get($description);

        $device{SERIAL}    = _getSerial($snmp, $model);
        $device{MAC}       = _getMacAddress($snmp, $model) || _getMacAddress($snmp);
        $device{MODELSNMP} = $model->{MODELSNMP};
        $device{TYPE}      = $model->{TYPE};

        $device{AUTHSNMP}     = $credential->{ID};
        $device{SNMPHOSTNAME} = $snmp->get('.1.3.6.1.2.1.1.5.0');

        $snmp->close();

        last;
    }

    return %device;
}

sub _getSerial {
    my ($snmp, $model) = @_;

    # the model is mandatory for the serial number
    return unless $model;
    return unless $model->{SERIAL};

    my $serial = $snmp->get($model->{SERIAL});
    if (defined($serial)) {
        $serial =~ s/\n//g;
        $serial =~ s/\r//g;
        $serial =~ s/^\s+//;
        $serial =~ s/\s+$//;
        $serial =~ s/(\.{2,})*//g;
    }

    return $serial;
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $macAddress;

    if ($model) {
        # use model-specific oids

        if ($model->{MAC}) {
            $macAddress = $snmp->get($model->{MAC});
        }

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            my $macs = $snmp->walk($model->{MACDYN});
            foreach my $value (values %{$macs}) {
                next if !$value;
                next if $value eq '0:0:0:0:0:0';
                next if $value eq '00:00:00:00:00:00';
                $macAddress = $value;
            }
        }
    } else {
        # use default oids

        $macAddress = $snmp->get(".1.3.6.1.2.1.17.1.1.0");

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            my $macs = $snmp->walk(".1.3.6.1.2.1.2.2.1.6");
            foreach my $value (values %{$macs}) {
                next if !$value;
                next if $value eq '0:0:0:0:0:0';
                next if $value eq '00:00:00:00:00:00';
                $macAddress = $value;
            }
        }
    }

    return $macAddress;
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
Copyright (C) 2010-2011 FusionInventory Team
