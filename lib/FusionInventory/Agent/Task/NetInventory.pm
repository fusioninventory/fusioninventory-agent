package FusionInventory::Agent::Task::NetInventory;

use strict;
use warnings;
use threads;
use threads::shared;
use base 'FusionInventory::Agent::Task';

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use Encode qw(encode);
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

# needed for perl < 5.10.1 compatbility
if ($threads::shared::VERSION < 1.21) {
    FusionInventory::Agent::Threads->use();
}

our $VERSION = '2.2.0';

# list of devices properties, indexed by XML element name
# the link to a specific OID is made by the model

# generic properties
my %properties = (
    MAC          => 'macaddr',
    CPU          => 'cpu',
    LOCATION     => 'location',
    FIRMWARE     => 'firmware',
    CONTACT      => 'contant',
    COMMENTS     => 'comments',
    UPTIME       => 'uptime',
    SERIAL       => 'serial',
    NAME         => 'name',
    MANUFACTURER => 'enterprise',
    OTHERSERIAL  => 'otherserial',
    MEMORY       => 'memory',
    RAM          => 'ram',
);

# printer catridge simple properties
my %printer_cartridges_simple_properties = (
    TONERBLACK            => 'tonerblack',
    TONERBLACK2           => 'tonerblack2',
    TONERCYAN             => 'tonercyan',
    TONERMAGENTA          => 'tonermagenta',
    TONERYELLOW           => 'toneryellow',
    WASTETONER            => 'wastetoner',
    CARTRIDGEBLACK        => 'cartridgeblack',
    CARTRIDGEBLACKPHOTO   => 'cartridgeblackphoto',
    CARTRIDGECYAN         => 'cartridgecyan',
    CARTRIDGECYANLIGHT    => 'cartridgecyanlight',
    CARTRIDGEMAGENTA      => 'cartridgemagenta',
    CARTRIDGEMAGENTALIGHT => 'cartridgemagentalight',
    CARTRIDGEYELLOW       => 'cartridgeyellow',
    MAINTENANCEKIT        => 'maintenancekit',
    DRUMBLACK             => 'drumblack',
    DRUMCYAN              => 'drumcyan',
    DRUMMAGENTA           => 'drummagenta',
    DRUMYELLOW            => 'drumyellow',
);

# printer cartridge percent properties
my %printer_cartridges_percent_properties = (
    BLACK                 => 'cartridgesblack',
    CYAN                  => 'cartridgescyan',
    YELLOW                => 'cartridgesyellow',
    MAGENTA               => 'cartridgesmagenta',
    CYANLIGHT             => 'cartridgescyanlight',
    MAGENTALIGHT          => 'cartridgesmagentalight',
    PHOTOCONDUCTOR        => 'cartridgesphotoconductor',
    PHOTOCONDUCTORBLACK   => 'cartridgesphotoconductorblack',
    PHOTOCONDUCTORCOLOR   => 'cartridgesphotoconductorcolor',
    PHOTOCONDUCTORCYAN    => 'cartridgesphotoconductorcyan',
    PHOTOCONDUCTORYELLOW  => 'cartridgesphotoconductoryellow',
    PHOTOCONDUCTORMAGENTA => 'cartridgesphotoconductormagenta',
    UNITTRANSFERBLACK     => 'cartridgesunittransfertblack',
    UNITTRANSFERCYAN      => 'cartridgesunittransfertcyan',
    UNITTRANSFERYELLOW    => 'cartridgesunittransfertyellow',
    UNITTRANSFERMAGENTA   => 'cartridgesunittransfertmagenta',
    WASTE                 => 'cartridgeswaste',
    FUSER                 => 'cartridgesfuser',
    BELTCLEANER           => 'cartridgesbeltcleaner',
    MAINTENANCEKIT        => 'cartridgesmaintenancekit',
);

# printer page counter properties
my %printer_pagecounters_properties = (
    TOTAL      => 'pagecountertotalpages',
    BLACK      => 'pagecounterblackpages',
    COLOR      => 'pagecountercolorpages',
    RECTOVERSO => 'pagecounterrectoversopages',
    SCANNED    => 'pagecounterscannedpages',
    PRINTTOTAL => 'pagecountertotalpages_print',
    PRINTBLACK => 'pagecounterblackpages_print',
    PRINTCOLOR => 'pagecountercolorpages_print',
    COPYTOTAL  => 'pagecountertotalpages_copy',
    COPYBLACK  => 'pagecounterblackpages_copy',
    COPYCOLOR  => 'pagecountercolorpages_copy',
    FAXTOTAL   => 'pagecountertotalpages_fax',
);

sub isEnabled {
    my ($self, $response) = @_;

    return unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    my $options = $self->getOptionsFromServer(
        $response, 'SNMPQUERY', 'SNMPQuery'
    );
    return unless $options;

    if (!$options->{DEVICE}) {
        $self->{logger}->debug("No device defined in the prolog response");
        return;
    }

    $self->{options} = $options;
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("FusionInventory NetInventory task $VERSION");

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
    my $max_threads = $options->{PARAM}->[0]->{THREADS_QUERY};

    # SNMP models
    my $models = _getIndexedModels($options->{MODEL});

    # SNMP credentials
    my $credentials = _getIndexedCredentials($options->{AUTHENTICATION});

    # create the required number of threads, sharing variables
    # for synchronisation
    my @devices :shared = map { shared_clone($_) } @{$options->{DEVICE}};
    my @results :shared;
    my @states  :shared;

    # no need for more threads than devices to scan
    if ($max_threads > @devices) {
        $max_threads = @devices;
    }

    #===================================
    # Create all Threads
    #===================================
    for (my $i = 0; $i < $max_threads; $i++) {
        $states[$i] = START;

        threads->create(
            '_queryDevices',
            $self,
            \$states[$i],
            \@devices,
            \@results,
            $models,
            $credentials,
        )->detach();
    }

    # send initial message to the server
    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });

    # set all threads in RUN state
    $_ = RUN foreach @states;

    # wait for all threads to reach EXIT state
    while (any { $_ != EXIT } @states) {
        delay(1);

        # send results to the server
        while (my $result = do { lock @results; shift @results; }) {
            my $data = {
                DEVICE        => $result,
                MODULEVERSION => $VERSION,
                PROCESSNUMBER => $pid
            };
            $self->_sendMessage($data);
        }
    }

    # send final message to the server
    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $pid
    });
}

sub _sendMessage {
    my ($self, $content) = @_;


   my $message = FusionInventory::Agent::XML::Query->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => $content
   );

   $self->{client}->send(
       url     => $self->{target}->getUrl(),
       message => $message
   );
}

sub _queryDevices {
    my ($self, $state, $devices, $results, $models, $credentials) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();

    $logger->debug("Thread $id created in PAUSE state");

    # start: wait for state to change
    while ($$state == START) {
        delay(1);
    }

    # run: process available addresses until exhaustion
    $logger->debug("Thread $id switched to RUN state");

    while (my $device = do { lock @{$devices}; shift @{$devices}; }) {

        my $result = $self->_queryDevice(
            device      => $device,
            model       => $models->{$device->{MODELSNMP_ID}},
            credentials => $credentials->{$device->{AUTHSNMP_ID}}
        );

        if ($result) {
            lock $results;
            push @$results, shared_clone($result);
        }

        delay(1);
    }

    $$state = EXIT;
    $logger->debug("Thread $id switched to EXIT state");
}

sub _getIndexedModels {
    my ($models) = @_;

    foreach my $model (@{$models}) {
        # index GET and WALK properties
        $model->{GET}  = { map { $_->{OBJECT} => $_ } @{$model->{GET}}  };
        $model->{WALK} = { map { $_->{OBJECT} => $_ } @{$model->{WALK}} };
    }

    # index models by their ID
    return { map { $_->{ID} => $_ } @{$models} };
}

sub _getIndexedCredentials {
    my ($credentials) = @_;

    # index credentials by their ID
    return { map { $_->{ID} => $_ } @{$credentials} };
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $credentials = $params{credentials};
    my $model       = $params{model};
    my $device      = $params{device};

    my $snmp;
    if ($device->{FILE}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{FILE}
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error("Unable to create SNMP session for $device->{FILE}: $EVAL_ERROR");
            return;
        }
    } else {
        eval {
            FusionInventory::Agent::SNMP::Live->require();
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                version      => $credentials->{VERSION},
                hostname     => $device->{IP},
                community    => $credentials->{COMMUNITY},
                username     => $credentials->{USERNAME},
                authpassword => $credentials->{AUTHPASSWORD},
                authprotocol => $credentials->{AUTHPROTOCOL},
                privpassword => $credentials->{PRIVPASSWORD},
                privprotocol => $credentials->{PRIVPROTOCOL},
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error("Unable to create SNMP session for $device->{IP}: $EVAL_ERROR");
            return;
        }
    }

    my $description = $snmp->get('.1.3.6.1.2.1.1.1.0');
    if (!$description) {
        return {
            ERROR => {
                ID      => $device->{ID},
                TYPE    => $device->{TYPE},
                MESSAGE => "No response from remote host"
            }
        };
    }

    # automatically extend model for cartridge support
    if ($device->{TYPE} eq "PRINTER") {
        foreach my $variable (values %{$model->{GET}}) {
            my $object = $variable->{OBJECT};
            if (
                $object eq "wastetoner"     ||
                $object eq "maintenancekit" ||
                $object =~ /^toner/         ||
                $object =~ /^cartridge/     ||
                $object =~ /^drum/
            ) {
                my $type_oid = $variable->{OID};
                $type_oid =~ s/43.11.1.1.6/43.11.1.1.8/;
                my $level_oid = $variable->{OID};
                $level_oid =~ s/43.11.1.1.6/43.11.1.1.9/;

                $model->{GET}->{"$object-capacitytype"} = {
                    OID  => $type_oid,
                    VLAN => 0,
                    OBJECT => "$object-capacitytype"
                };
                $model->{GET}->{"$object-level"} = {
                    OID  => $level_oid,
                    VLAN => 0,
                    OBJECT => "$object-level"
                };
            }
        }
    }

    # first, fetch values from device
    my $results;
    foreach my $variable (values %{$model->{GET}}) {
        $results->{$variable->{OBJECT}} = $snmp->get($variable->{OID});
    }
    foreach my $variable (values %{$model->{WALK}}) {
        next if $variable->{VLAN};
        $results->{$variable->{OBJECT}} = $snmp->walk($variable->{OID});
    }

    # second, use results to build the object
    my $datadevice = {
        INFO => {
            ID   => $device->{ID},
            TYPE => $device->{TYPE},
            getBasicInfoFromSysdescr($description, $snmp)
        }
    };



    $self->_setGenericProperties(
        results => $results,
        device  => $datadevice,
        walks   => $model->{WALK}
    );

    $self->_setPrinterProperties(
        results => $results,
        device  => $datadevice,
    ) if $device->{TYPE} eq 'PRINTER';

    $self->_setNetworkingProperties(
        results     => $results,
        device      => $datadevice,
        walks       => $model->{WALK},
        host        => $device->{IP},
        credentials => $credentials
    ) if $device->{TYPE} eq 'NETWORKING';

    # convert ports hashref to an arrayref, sorted by interface number
    my $ports = $datadevice->{PORTS}->{PORT};
    $datadevice->{PORTS}->{PORT} = [
        map { $ports->{$_} }
        sort { $a <=> $b }
        keys %{$ports}
    ];

    return $datadevice;
}

sub _setGenericProperties {
    my ($self, %params) = @_;

    my $results = $params{results};
    my $device  = $params{device};

    if ($results->{cpuuser}) {
        $device->{INFO}->{CPU} =
            $results->{cpuuser} + $results->{cpusystem};
    }

    if ($results->{firmware1}) {
        $device->{INFO}->{FIRMWARE} = $results->{firmware1};
    }
    if ($results->{firmware2}) {
        if ($device->{INFO}->{FIRMWARE}) {
            $device->{INFO}->{FIRMWARE} .= ' ' ;
        }
        $device->{INFO}->{FIRMWARE} .= $results->{firmware2};
    }

    foreach my $key (keys %properties) {
        # don't overwrite known values
        next if $device->{INFO}->{$key};

        my $raw_value = $results->{$properties{$key}};
        next unless defined $raw_value;
        my $value =
            $key eq 'NAME'        ? hex2char($raw_value)                           :
            $key eq 'LOCATION'    ? hex2char($raw_value)                           :
            $key eq 'SERIAL'      ? getSanitizedSerialNumber(hex2char($raw_value)) :
            # OTHERSERIAL can be either:
            #  - a number in hex
            #  - a number
            #  - a string in hex
            # if we use a number as a string, we can garbage char. For example for:
            #  - 0x0115
            #  - 0xfde8
            $key eq 'OTHERSERIAL' ? getSanitizedSerialNumber($raw_value)           :
            $key eq 'RAM'         ? int($raw_value / 1024 / 1024)                  :
            $key eq 'MEMORY'      ? int($raw_value / 1024 / 1024)                  :
                                    hex2char($raw_value)                           ;

        if ($key eq 'MAC') {
            if ($raw_value =~ $mac_address_pattern) {
                $value = $raw_value;
            } else {
                $value = alt2canonical($raw_value);
            }
        }

        $device->{INFO}->{$key} = $value;

    }

    if ($results->{ipAdEntAddr}) {
        $device->{INFO}->{IPS}->{IP} = [
            values %{$results->{ipAdEntAddr}}
        ];
    }

    # ports is a sparse list of network ports, indexed by native port number
    my $ports;

    if ($results->{ifIndex}) {
        while (my ($oid, $data) = each %{$results->{ifIndex}}) {
            $ports->{getLastElement($oid)}->{IFNUMBER} = $data;
        }
    }

    if ($results->{ifdescr}) {
        while (my ($oid, $data) = each %{$results->{ifdescr}}) {
            $ports->{getLastElement($oid)}->{IFDESCR} = $data;
        }
    }

    if ($results->{ifName}) {
        while (my ($oid, $data) = each %{$results->{ifName}}) {
            $ports->{getLastElement($oid)}->{IFNAME} = $data;
        }
    }

    if ($results->{ifType}) {
        while (my ($oid, $data) = each %{$results->{ifType}}) {
            $ports->{getLastElement($oid)}->{IFTYPE} = $data;
        }
    }

    if ($results->{ifmtu}) {
        while (my ($oid, $data) = each %{$results->{ifmtu}}) {
            $ports->{getLastElement($oid)}->{IFMTU} = $data;
        }
    }

    if ($results->{ifspeed}) {
        while (my ($oid, $data) = each %{$results->{ifspeed}}) {
            $ports->{getLastElement($oid)}->{IFSPEED} = $data;
        }
    }

    if ($results->{ifstatus}) {
        while (my ($oid, $data) = each %{$results->{ifstatus}}) {
            $ports->{getLastElement($oid)}->{IFSTATUS} = $data;
        }
    }

    if ($results->{ifinternalstatus}) {
        while (my ($oid, $data) = each %{$results->{ifinternalstatus}}) {
            $ports->{getLastElement($oid)}->{IFINTERNALSTATUS} = $data;
        }
    }

    if ($results->{iflastchange}) {
        while (my ($oid, $data) = each %{$results->{iflastchange}}) {
            $ports->{getLastElement($oid)}->{IFLASTCHANGE} = $data;
        }
    }

    if ($results->{ifinoctets}) {
        while (my ($oid, $data) = each %{$results->{ifinoctets}}) {
            $ports->{getLastElement($oid)}->{IFINOCTETS} = $data;
        }
    }

    if ($results->{ifoutoctets}) {
        while (my ($oid, $data) = each %{$results->{ifoutoctets}}) {
            $ports->{getLastElement($oid)}->{IFOUTOCTETS} = $data;
        }
    }

    if ($results->{ifinerrors}) {
        while (my ($oid, $data) = each %{$results->{ifinerrors}}) {
            $ports->{getLastElement($oid)}->{IFINERRORS} = $data;
        }
    }

    if ($results->{ifouterrors}) {
        while (my ($oid, $data) = each %{$results->{ifouterrors}}) {
            $ports->{getLastElement($oid)}->{IFOUTERRORS} = $data;
        }
    }

    if ($results->{ifPhysAddress}) {
        while (my ($oid, $data) = each %{$results->{ifPhysAddress}}) {
            next unless $data;
            $ports->{getLastElement($oid)}->{MAC} = alt2canonical($data);
        }
    }

    if ($results->{ifaddr}) {
        while (my ($oid, $data) = each %{$results->{ifaddr}}) {
            next unless $data;
            my $address = $oid;
            $address =~ s/$params{walks}->{ifaddr}->{OID}//;
            $address =~ s/^.//;
            $ports->{$data}->{IP} = $address;
        }
    }

    if ($results->{portDuplex}) {
        while (my ($oid, $data) = each %{$results->{portDuplex}}) {
            $ports->{getLastElement($oid)}->{IFPORTDUPLEX} = $data;
        }
    }

    $device->{PORTS}->{PORT} = $ports;
}

sub _setPrinterProperties {
    my ($self, %params) = @_;

    my $results = $params{results};
    my $device  = $params{device};

    $device->{INFO}->{MODEL} = $results->{model};

    # consumable levels
    foreach my $key (keys %printer_cartridges_simple_properties) {
        my $property = $printer_cartridges_simple_properties{$key};

        next unless defined($results->{$property . '-level'});

        my $value =
            $results->{$property . '-level'} == -3 ?
                100 :
                _getPercentValue(
                    $results->{$property . '-capacitytype'},
                    $results->{$property . '-level'},
                );
        next unless $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }
    foreach my $key (keys %printer_cartridges_percent_properties) {
        my $property = $printer_cartridges_percent_properties{$key};
        my $value = _getPercentValue(
            $results->{$property . 'MAX'},
            $results->{$property . 'REMAIN'},
        );
        next unless $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_properties) {
        my $property = $printer_pagecounters_properties{$key};
        $device->{PAGECOUNTERS}->{$key} =
            $results->{$property};
    }
}

sub _setNetworkingProperties {
    my ($self, %params) = @_;

    my $results = $params{results};
    my $device  = $params{device};
    my $walks   = $params{walks};

    $device->{INFO}->{MODEL} = $results->{entPhysicalModelName};

    my $comments = $device->{INFO}->{COMMENTS};
    my $ports    = $device->{PORTS}->{PORT};

    # Detect VLAN
    if ($results->{vmvlan}) {
        while (my ($oid, $vlan_id) = each %{$results->{vmvlan}}) {
            my $port_id  = getLastElement($oid);
            my $vlan_oid = $walks->{vtpVlanName}->{OID} . "." . $vlan_id;
            my $name = $results->{vtpVlanName}->{$vlan_oid};
            push
                @{$ports->{$port_id}->{VLANS}->{VLAN}},
                    {
                        NUMBER => $vlan_id,
                        NAME   => $name
                    };
        }
    }

    # everything else is vendor-specific, and requires device description
    return unless $comments;

    _setTrunkPorts($comments, $results, $ports);

    _setConnectedDevices($comments, $results, $ports, $walks);

    # check if vlan-specific queries are needed
    my $vlan_query =
        any { $_->{VLAN} }
        values %{$walks};

    if ($vlan_query) {
        my $host        = $params{host};
        my $credentials = $params{credentials};
        # set connected devices mac addresses for each VLAN
        while (my ($oid, $name) = each %{$results->{vtpVlanName}}) {
            my $vlan_id = getLastElement($oid);
            # initiate a new SNMP connection on this VLAN
            my $snmp;
            eval {
                $snmp = FusionInventory::Agent::SNMP::Live->new(
                    version      => $credentials->{VERSION},
                    hostname     => $host,
                    community    => $credentials->{COMMUNITY} . "@" . $vlan_id,
                    username     => $credentials->{USERNAME},
                    authpassword => $credentials->{AUTHPASSWORD},
                    authprotocol => $credentials->{AUTHPROTOCOL},
                    privpassword => $credentials->{PRIVPASSWORD},
                    privprotocol => $credentials->{PRIVPROTOCOL},
                );
            };
            if ($EVAL_ERROR) {
                $self->{logger}->error(
                    "Unable to create SNMP session for $host, VLAN $vlan_id: " .
                    $EVAL_ERROR
                );
                return;
            }

            foreach my $variable (values %{$walks}) {
                next unless $variable->{VLAN};
                $results->{VLAN}->{$vlan_id}->{$variable->{OBJECT}} =
                    $snmp->walk($variable->{OID});
            }

            _setConnectedDevicesMacAddresses(
                $comments, $results, $ports, $walks, $vlan_id
            );
        }
    } else {
        # set connected devices mac addresses only once
        _setConnectedDevicesMacAddresses($comments, $results, $ports, $walks);
    }

    # hardware-specific hacks
    _performSpecificCleanup($comments, $results, $ports);
}

sub _setTrunkPorts {
    my ($description, $results, $ports) = @_;

    my @dispatch_table = (
        {
            match  => qr/(Cisco|ProCurve)/,
            module => 'FusionInventory::Agent::Manufacturer',
        },
        {
            match  => qr/Nortel/,
            module => 'FusionInventory::Agent::Manufacturer::Nortel',
        },
    );

    foreach my $entry (@dispatch_table) {
        next unless $description =~ $entry->{match};

        runFunction(
            module   => $entry->{module},
            function => 'setTrunkPorts',
            params   => { results => $results, ports => $ports },
            load     => 1
        );

        last;
    }

}

sub _setConnectedDevices {
    my ($description, $results, $ports, $walks) = @_;

    my @dispatch_table = (
        {
            match  => qr/(Cisco|ProCurve|Juniper)/,
            module => 'FusionInventory::Agent::Manufacturer',
        },
        {
            match  => qr/Nortel/,
            module => 'FusionInventory::Agent::Manufacturer::Nortel',
        },
    );

    foreach my $entry (@dispatch_table) {
        next unless $description =~ $entry->{match};

        runFunction(
            module   => $entry->{module},
            function => 'setConnectedDevices',
            params   => {
                results => $results, ports => $ports, walks => $walks
            },
            load     => 1
        );

        last;
    }
}

sub _setConnectedDevicesMacAddresses {
    my ($description, $results, $ports, $walks, $vlan_id) = @_;

    my @dispatch_table = (
        {
            match    => qr/(3Com|ProCurve|Nortel|Allied Telesis)/,
            module   => 'FusionInventory::Agent::Manufacturer',
        },
        {
            match    => qr/Cisco/,
            module   => 'FusionInventory::Agent::Manufacturer::Cisco',
        },
        {
            match    => qr/Juniper/,
            module   => 'FusionInventory::Agent::Manufacturer::Juniper',
        }
    );

    foreach my $entry (@dispatch_table) {
        next unless $description =~ $entry->{match};

        runFunction(
            module   => $entry->{module},
            function => 'setConnectedDevicesMacAddresses',
            params   => {
                results => $results,
                ports   => $ports,
                walks   => $walks,
                vlan_id => $vlan_id
            },
            load     => 1
        );

        last;
    }
}

sub _performSpecificCleanup {
    my ($description, $results, $ports, $walks) = @_;

    my @dispatch_table = (
        {
            match    => qr/3Com IntelliJack/,
            module   => 'FusionInventory::Agent::Manufacturer::3Com',
            function => 'RewritePortOf225'
        },
    );

    foreach my $entry (@dispatch_table) {
        next unless $description =~ $entry->{match};

        runFunction(
            module   => $entry->{module},
            function => $entry->{function},
            params   => {
                results => $results,
                ports   => $ports
            },
            load     => 1
        );

        last;
    }
}

sub _getPercentValue {
    my ($value1, $value2) = @_;

    return unless defined $value1 && _isInteger($value1);
    return unless defined $value2 && _isInteger($value2);
    return if $value1 == 0;

    return int(
        ( 100 * $value2 ) / $value1
    );
}

sub _isInteger {
    $_[0] =~ /^[+-]?\d+$/;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory - Remote inventory support for FusionInventory Agent

=head1 DESCRIPTION

This task extracts various information from remote hosts through SNMP
protocol:

=over

=item *

printer cartridges and counters status

=item *

router/switch ports status

=item *

relations between devices and router/switch ports

=back

This task requires a GLPI server with FusionInventory plugin.

=head1 AUTHORS

Copyright (C) 2009 David Durieux
Copyright (C) 2010-2012 FusionInventory Team
