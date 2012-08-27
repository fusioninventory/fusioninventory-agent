package FusionInventory::Agent::Task::NetDiscovery;

use strict;
use warnings;
use threads;
use threads::shared;
use base 'FusionInventory::Agent::Task';

use constant DEVICE_PER_MESSAGE => 4;

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use English qw(-no_match_vars);
use Net::IP;
use Time::localtime;
use UNIVERSAL::require;
use XML::TreePP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::XML::Query;

# needed for perl < 5.10.1 compatbility
if ($threads::shared::VERSION < 1.21) {
    FusionInventory::Agent::Threads->use();
}

our $VERSION = '2.2.0';

my %hardware_keywords = (
    '3com'           => { vendor => '3Com',            type => 'NETWORKING' },
    'alcatel-lucent' => { vendor => 'Alcatel-Lucent',  type => 'NETWORKING' },
    'allied'         => { vendor => 'Allied',          type => 'NETWORKING' },
    'alteon'         => { vendor => 'Alteon',          type => 'NETWORKING' },
    'apc'            => { vendor => 'APC',             type => 'NETWORKING' },
    'apple'          => { vendor => 'Apple',           type => 'NETWORKING' },
    'avaya'          => { vendor => 'Avaya',           type => 'NETWORKING' },
    'axis'           => { vendor => 'Axis',            type => 'NETWORKING' },
    'baystack'       => { vendor => 'Nortel',          type => 'NETWORKING' },
    'broadband'      => { vendor => 'Broadband',       type => 'NETWORKING' },
    'brocade'        => { vendor => 'Brocade',         type => 'NETWORKING' },
    'brother'        => { vendor => 'Brother',         type => 'NETWORKING' },
    'canon'          => { vendor => 'Canon',           type => 'PRINTER'    },
    'cisco'          => { vendor => 'Cisco',           type => 'NETWORKING' },
    'dell'           => { vendor => 'Dell',            type => 'NETWORKING' },
    'designjet'      => { vendor => 'Hewlett Packard', type => 'PRINTER'    },
    'deskjet'        => { vendor => 'Hewlett Packard', type => 'PRINTER'    },
    'dlink'          => { vendor => 'Dlink',           type => 'NETWORKING' },
    'eaton'          => { vendor => 'Eaton',           type => 'NETWORKING' },
    'emc'            => { vendor => 'EMC',                                  },
    'enterasys'      => { vendor => 'Enterasys',       type => 'NETWORKING' },
    'epson'          => { vendor => 'Epson',           type => 'PRINTER'    },
    'extreme'        => { vendor => 'Extrem Networks', type => 'NETWORKING' },
    'extremexos'     => { vendor => 'Extrem Networks', type => 'NETWORKING' },
    'foundry'        => { vendor => 'Foundry',         type => 'NETWORKING' },
    'fuji'           => { vendor => 'Fuji',            type => 'NETWORKING' },
    'h3c'            => { vendor => 'H3C',             type => 'NETWORKING' },
    'hp'             => { vendor => 'Hewlett Packard',                      },
    'ibm'            => { vendor => 'IBM',             type => 'NETWORKING' },
    'juniper'        => { vendor => 'Juniper',         type => 'NETWORKING' },
    'konica'         => { vendor => 'Konica',          type => 'PRINTER'    },
    'kyocera'        => { vendor => 'Kyocera',         type => 'PRINTER'    },
    'lexmark'        => { vendor => 'Lexmark',         type => 'PRINTER'    },
    'netapp'         => { vendor => 'NetApp',                               },
    'netgear'        => { vendor => 'NetGear',         type => 'NETWORKING' },
    'nortel'         => { vendor => 'Nortel',          type => 'NETWORKING' },
    'nrg'            => { vendor => 'NRG',             type => 'NETWORKING' },
    'officejet'      => { vendor => 'Hewlett Packard', type => 'PRINTER'    },
    'oki'            => { vendor => 'OKI',             type => 'PRINTER'    },
    'powerconnect'   => { vendor => 'PowerConnect',    type => 'NETWORKING' },
    'procurve'       => { vendor => 'Hewlett Packard', type => 'NETWORKING' },
    'ricoh'          => { vendor => 'Ricoh',           type => 'PRINTER'    },
    'sagem'          => { vendor => 'Sagem',           type => 'NETWORKING' },
    'samsung'        => { vendor => 'Samsung',         type => 'NETWORKING' },
    'sharp'          => { vendor => 'Sharp',           type => 'NETWORKING' },
    'toshiba'        => { vendor => 'Toshiba',         type => 'NETWORKING' },
    'wyse'           => { vendor => 'Wyse',            type => 'NETWORKING' },
    'xerox'          => { vendor => 'Xerox',           type => 'PRINTER'    },
    'xirrus'         => { vendor => 'Xirrus',          type => 'NETWORKING' },
    'zebranet'       => { vendor => 'Zebranet',        type => 'NETWORKING' },
    'ztc'            => { vendor => 'ZTC',             type => 'NETWORKING' },
    'zywall'         => { vendor => 'ZyWall',          type => 'NETWORKING' }
);

my @hardware_rules = (
    {
        match       => qr/^\S+ Service Release/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Alcatel::getDescription' },
        vendor      => { value    => 'Alcatel' }
    },
    {
        match       => qr/AXIS OfficeBasic Network Print Server/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Axis::getDescription' },
        vendor      => { value    => 'Axis' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/Linux/,
        description => { oid   => '.1.3.6.1.2.1.1.5.0' },
        vendor      => { value => 'Ddwrt' }
    },
    {
        match       => qr/^Ethernet Switch$/,
        description => { oid   => '.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0' },
        vendor      => { value => 'Dell' },
        type        => { value => 'NETWORKING' }
    },
    {
        match       => qr/EPSON Built-in/,
        description => { oid   => '.1.3.6.1.4.1.1248.1.1.3.1.3.8.0' },
        vendor      => { value => 'Epson' },
    },
    {
        match       => qr/EPSON Internal 10Base-T/,
        description => { oid   => '.1.3.6.1.2.1.25.3.2.1.3.1' },
        vendor      => { value => 'Epson' },
    },
    {
        match       => qr/HP ETHERNET MULTI-ENVIRONMENT/,
        description => { function => 'FusionInventory::Agent::Manufacturer::HewlettPackard::getDescription' },
        vendor      => { value    => 'Hewlett-Packard' }
    },
    {
        match       => qr/A SNMP proxy agent, EEPROM/,
        description => { function => 'FusionInventory::Agent::Manufacturer::HewlettPackard::getDescription' },
        vendor      => { value    => 'Hewlett-Packard' }
    },
    {
        match       => qr/,HP,JETDIRECT,J/,
        description => { oid   => '.1.3.6.1.4.1.1229.2.2.2.1.15.1' },
        vendor      => { value => 'Kyocera' },
        type        => { value => 'PRINTER' }
    },
    {
        match       => qr/^KYOCERA (MITA Printing System|Print I\/F)$/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Kyocera::getDescription' },
        vendor      => { value    => 'Kyocera' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/^SB-110$/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Kyocera::getDescription' },
        vendor      => { value    => 'Kyocera' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/RICOH NETWORK PRINTER/,
        description => { oid => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0' },
        vendor      => { value => 'Ricoh' },
        type        => { value => 'PRINTER' }
    },
    {
        match       => qr/SAMSUNG NETWORK PRINTER,ROM/,
        description => { oid => '.1.3.6.1.4.1.236.11.5.1.1.1.1.0' },
        vendor      => { value => 'Samsung' },
        type        => { value => 'PRINTER' }
    },
    {
        match       => qr/Samsung(.*);S\/N(.*)/,
        description => { oid => '.1.3.6.1.4.1.236.11.5.1.1.1.1.0' }
    },
    {
        match        => qr/Linux/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Wyse::getDescription' },
        vendor      => { value    => 'Wyse' },
    },
    {
        match       => qr/ZebraNet PrintServer/,
        description => { function => 'FusionInventory::Agent::::Manufacturer::Zebranet::getDescription' },
        vendor      => { value    => 'Zebranet' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/ZebraNet Wired PS/,
        description => { function => 'FusionInventory::Agent::Manufacturer::Zebranet::getDescription' },
        vendor      => { value    => 'Zebranet' },
    },
);

sub isEnabled {
    my ($self, $response) = @_;

    return unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

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

    $self->{logger}->debug("FusionInventory NetDiscovery task $VERSION");

    # task-specific client, if needed
    $self->{client} = FusionInventory::Agent::HTTP::Client::OCS->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    ) if !$self->{client};

    my $options     = $self->{options};
    my $pid         = $options->{PARAM}->[0]->{PID};
    my $max_threads = $options->{PARAM}->[0]->{THREADS_DISCOVERY};

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
        $snmp_dictionary = $self->_getDictionary($options, $pid);
        # abort immediatly if the dictionary isn't up to date
        return unless $snmp_dictionary;
    }


    # create the required number of threads, sharing variables
    # for synchronisation
    my @addresses :shared;
    my @results   :shared;
    my @states    :shared;

    # compute blocks list
    my $addresses_count = 0;
    foreach my $range (@{$options->{RANGEIP}}) {
        next unless $range->{IPSTART};
        next unless $range->{IPEND};
        $range->{block} = Net::IP->new(
            $range->{IPSTART} . '-' . $range->{IPEND}
        );
        $addresses_count += $range->{block}->size();
    }

    # no need for more threads than addresses to scan
    if ($max_threads > $addresses_count) {
        $max_threads = $addresses_count;
    }

    for (my $i = 0; $i < $max_threads; $i++) {
        $states[$i] = START;

        threads->create(
            '_scanAddresses',
            $self,
            \$states[$i],
            \@addresses,
            \@results,
            $snmp_credentials,
            $snmp_dictionary,
            $nmap_parameters,
        )->detach();
    }

    # send initial message to the server
    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

    # set all threads in RUN state
    $_ = RUN foreach @states;

    # proceed each given IP block
    foreach my $range (@{$options->{RANGEIP}}) {
        my $block = $range->{block};
        next unless $block;
        do {
            push @addresses, $block->ip(),
        } while (++$block);
        $self->{logger}->debug(
            "scanning range: $range->{IPSTART}-$range->{IPEND}"
        );

        # send block size to the server
        $self->_sendMessage({
            AGENT => {
                NBIP => scalar @addresses
            },
            PROCESSNUMBER => $pid
        });

        # set all threads in RUN state
        $_ = RUN foreach @states;

        # wait for all threads to reach STOP state
        while (any { $_ != STOP } @states) {
            delay(1);

            # send results to the server
            while (my $result = do { lock @results; shift @results; }) {
                $result->{ENTITY} = $range->{ENTITY} if $range->{ENTITY};
                my $data = {
                    DEVICE        => [$result],
                    MODULEVERSION => $VERSION,
                    PROCESSNUMBER => $pid,
                };
                $self->_sendMessage($data);
            }
        }
    }

    # set all threads in EXIT state
    $_ = EXIT foreach @states;
    delay(1);

    # send final message to the server
    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

}

sub _getDictionary {
    my ($self, $options, $pid) = @_;

    my ($dictionary, $hash);
    my $storage = $self->{target}->getStorage();

    if ($options->{DICO}) {
        # the server message contains a dictionary, use it
        # and save it for later use
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
        if ($hash && $hash eq $options->{DICOHASH}) {
            $self->{logger}->debug("Dictionary is up to date.");
        } else {
            # Send dictionary update request
            $self->_sendMessage({
                AGENT => {
                    END => '1'
                },
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid,
                DICO          => "REQUEST",
            });
            $self->{logger}->debug($hash ?
                "Dictionary is outdated, update request sent, exiting" :
                "No dictionary, update request sent, exiting"
            );
            return;
        }
    }

    $self->{logger}->debug("Dictionary loaded.");

    return $dictionary;
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

sub _scanAddresses {
    my ($self, $state, $addresses, $results, $snmp_credentials, $snmp_dictionary, $nmap_parameters) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();
    
    $logger->debug("Thread $id created");

    # start: wait for state to change
    while ($$state == START) {
        delay(1);
    }

    OUTER: while (1) {
        # run: process available addresses until exhaustion
        $logger->debug("Thread $id switched to RUN state");

        while (my $address = do { lock @{$addresses}; shift @{$addresses}; }) {

            my $result = $self->_scanAddress(
                ip               => $address,
                nmap_parameters  => $nmap_parameters,
                snmp_credentials => $snmp_credentials,
                snmp_dictionary  => $snmp_dictionary
            );

            if ($result) {
                lock $results;
                push @$results, shared_clone($result);
            }
        }

        # stop: wait for state to change
        $$state = STOP;
        $logger->debug("Thread $id switched to STOP state");
        while ($$state == STOP) {
            delay(1);
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

    my $logger = $self->{logger};
    my $id     = threads->tid();
    $logger->debug("thread $id: scanning $params{ip}");

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
        $logger->debug("thread $id: device found for $params{ip}");
        return \%device;
    } else {
        $logger->debug("thread $id: nothing found for $params{ip}");
        return;
    }
}

sub _scanAddressByNmap {
    my ($self, %params) = @_;

    my $device = _parseNmap(
        command => "nmap $params{nmap_parameters} $params{ip} -oX -"
    );

    $self->{logger}->debug2(
        sprintf "thread %d: scanning %s with nmap: %s",
        threads->tid(),
        $params{ip},
        $device ? 'success' : 'failure'
    );

    return $device ? %$device : ();
}

sub _scanAddressByNetbios {
    my ($self, %params) = @_;

    my $nb = Net::NBName->new();

    my $ns = $nb->node_status($params{ip});

    $self->{logger}->debug2(
        sprintf "thread %d: scanning %s with netbios: %s",
        threads->tid(),
        $params{ip},
        $ns ? 'success' : 'failure'
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

    my %device;
    foreach my $credential (@{$params{snmp_credentials}}) {

        my $snmp;
        eval {
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                version      => $credential->{VERSION},
                hostname     => $params{ip},
                community    => $credential->{COMMUNITY},
                username     => $credential->{USERNAME},
                authpassword => $credential->{AUTHPASSWORD},
                authprotocol => $credential->{AUTHPROTOCOL},
                privpassword => $credential->{PRIVPASSWORD},
                privprotocol => $credential->{PRIVPROTOCOL},
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error(
                "Unable to create SNMP session for $params{ip}: $EVAL_ERROR"
            );
            next;
        }

        # SNMPv2-MIB::sysDescr.0
        my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');

        $self->{logger}->debug2(
            sprintf "thread %d: scanning %s with snmp credentials %d: %s",
            threads->tid(),
            $params{ip},
            $credential->{ID},
            $sysdescr ? 'success' : 'failure'
        );

        # no sysdescr means invalid credentials
        next unless $sysdescr;

        # try to get a matching model from the dictionary
        my $model = $params{snmp_dictionary}->getModel($sysdescr);

        if ($model) {
            # use model as primary identification source

            $device{SERIAL}    = _getSerial($snmp, $model);
            $device{MAC}       = _getMacAddress($snmp, $model) ||
                                 _getMacAddress($snmp);
            $device{MODELSNMP}    = $model->{MODELSNMP};
            $device{TYPE}         = $model->{TYPE};
            $device{MANUFACTURER} = $model->{MANUFACTURER};
            $device{FIRMWARE}     = $model->{FIRMWARE};
            $device{MODEL}        = $model->{MODEL};

            foreach my $rule (@hardware_rules) {
                next unless $sysdescr =~ $rule->{match};
                $device{DESCRIPTION} = _apply_rule($rule->{description}, $snmp);
                last;
            }
        } else {
            # use rules as fallback

            $device{MAC} = _getMacAddress($snmp);

            my ($first_word) = $sysdescr =~ /^(\S+)/;
            my $keyword = $hardware_keywords{lc($first_word)};

            if ($keyword) {
                $device{MANUFACTURER} = $keyword->{vendor};
                $device{TYPE}         = $keyword->{type};
            } else {
                foreach my $rule (@hardware_rules) {
                    next unless $sysdescr =~ $rule->{match};
                    $device{MANUFACTURER} = _apply_rule($rule->{vendor}, $snmp);
                    $device{TYPE}         = _apply_rule($rule->{type}, $snmp);
                    $device{DESCRIPTION}  = _apply_rule($rule->{description}, $snmp);
                    last;
                }
            }
        }

        $device{AUTHSNMP}     = $credential->{ID};
        # SNMPv2-MIB::sysName.0
        $device{SNMPHOSTNAME} = $snmp->get('.1.3.6.1.2.1.1.5.0');
        $device{DESCRIPTION}  = $sysdescr if !$device{DESCRIPTION};

        last;
    }

    return %device;
}

sub _getSerial {
    my ($snmp, $model) = @_;

    # the model is mandatory for the serial number
    return unless $model;
    return unless $model->{SERIAL};

    return $snmp->getSerialNumber($model->{SERIAL});
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $macAddress;

    if ($model) {
        # use model-specific oids

        if ($model->{MAC}) {
            $macAddress = $snmp->getMacAddress($model->{MAC});
        }

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            my $macs = $snmp->walkMacAddresses($model->{MACDYN});
            foreach my $value (values %{$macs}) {
                next if !$value;
                next if $value eq '0:0:0:0:0:0';
                next if $value eq '00:00:00:00:00:00';
                $macAddress = $value;
            }
        }
    } else {
        # use default oids

        # SNMPv2-SMI::mib-2.17.1.1.0
        $macAddress = $snmp->getMacAddress(".1.3.6.1.2.1.17.1.1.0");

        if (!$macAddress || $macAddress !~ /^$mac_address_pattern$/) {
            # IF-MIB::ifPhysAddress
            my $macs = $snmp->walkMacAddresses(".1.3.6.1.2.1.2.2.1.6");
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

sub _apply_rule {
    my ($rule, $snmp) = @_;

    return unless $rule;

    if ($rule->{value}) {
        return $rule->{value};
    }

    if ($rule->{oid}) {
        return $snmp->get($rule->{oid});
    }

    if ($rule->{function}) {
        my ($module, $function) = $rule->{function} =~ /^(\S+)::(\S+)$/;
        return runFunction(
            module   => $module,
            function => $function,
            params   => $snmp,
            load     => 1
        );
    }
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
