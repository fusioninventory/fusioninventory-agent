package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools; # runFunction
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

our @EXPORT = qw(
    getDeviceBaseInfo
    getDeviceInfo
    getDeviceFullInfo
);

my %hardware_keywords = (
    '3com'           => { vendor => '3Com',            type => 'NETWORKING' },
    'alcatel-lucent' => { vendor => 'Alcatel-Lucent',  type => 'NETWORKING' },
    'allied'         => { vendor => 'Allied',          type => 'NETWORKING' },
    'alteon'         => { vendor => 'Alteon',          type => 'NETWORKING' },
    'apc'            => { vendor => 'APC',             type => 'NETWORKING' },
    'apple'          => { vendor => 'Apple',                                },
    'avaya'          => { vendor => 'Avaya',           type => 'NETWORKING' },
    'axis'           => { vendor => 'Axis',            type => 'NETWORKING' },
    'baystack'       => { vendor => 'Nortel',          type => 'NETWORKING' },
    'broadband'      => { vendor => 'Broadband',       type => 'NETWORKING' },
    'brocade'        => { vendor => 'Brocade',         type => 'NETWORKING' },
    'brother'        => { vendor => 'Brother',         type => 'PRINTER'    },
    'canon'          => { vendor => 'Canon',           type => 'PRINTER'    },
    'cisco'          => { vendor => 'Cisco',           type => 'NETWORKING' },
    'dell'           => { vendor => 'Dell',                                 },
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
    'hp'             => { vendor => 'Hewlett Packard', type => 'PRINTER'    },
    'ibm'            => { vendor => 'IBM',             type => 'COMPUTER'   },
    'juniper'        => { vendor => 'Juniper',         type => 'NETWORKING' },
    'konica'         => { vendor => 'Konica',          type => 'PRINTER'    },
    'kyocera'        => { vendor => 'Kyocera',         type => 'PRINTER'    },
    'lexmark'        => { vendor => 'Lexmark',         type => 'PRINTER'    },
    'netapp'         => { vendor => 'NetApp',                               },
    'netgear'        => { vendor => 'NetGear',         type => 'NETWORKING' },
    'nortel'         => { vendor => 'Nortel',          type => 'NETWORKING' },
    'nrg'            => { vendor => 'NRG',             type => 'PRINTER'    },
    'officejet'      => { vendor => 'Hewlett Packard', type => 'PRINTER'    },
    'oki'            => { vendor => 'OKI',             type => 'PRINTER'    },
    'powerconnect'   => { vendor => 'PowerConnect',    type => 'NETWORKING' },
    'procurve'       => { vendor => 'Hewlett Packard', type => 'NETWORKING' },
    'ricoh'          => { vendor => 'Ricoh',           type => 'PRINTER'    },
    'sagem'          => { vendor => 'Sagem',           type => 'NETWORKING' },
    'samsung'        => { vendor => 'Samsung',         type => 'PRINTER'    },
    'sharp'          => { vendor => 'Sharp',           type => 'PRINTER'    },
    'toshiba'        => { vendor => 'Toshiba',         type => 'PRINTER'    },
    'wyse'           => { vendor => 'Wyse',            type => 'COMPUTER'   },
    'xerox'          => { vendor => 'Xerox',           type => 'PRINTER'    },
    'xirrus'         => { vendor => 'Xirrus',          type => 'NETWORKING' },
    'zebranet'       => { vendor => 'Zebranet',        type => 'PRINTER'    },
    'ztc'            => { vendor => 'ZTC',             type => 'NETWORKING' },
    'zywall'         => { vendor => 'ZyWall',          type => 'NETWORKING' }
);

my @hardware_rules = (
    {
        match       => qr/^\S+ Service Release/,
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Alcatel::getDescription' },
        vendor      => { value    => 'Alcatel' }
    },
    {
        match       => qr/AXIS OfficeBasic Network Print Server/,
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Axis::getDescription' },
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
        description => { function => 'FusionInventory::Agent::Tools::Hardware::HewlettPackard::getDescription' },
        vendor      => { value    => 'Hewlett-Packard' }
    },
    {
        match       => qr/A SNMP proxy agent, EEPROM/,
        description => { function => 'FusionInventory::Agent::Tools::Hardware::HewlettPackard::getDescription' },
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
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Kyocera::getDescription' },
        vendor      => { value    => 'Kyocera' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/^SB-110$/,
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Kyocera::getDescription' },
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
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Wyse::getDescription' },
        vendor      => { value    => 'Wyse' },
    },
    {
        match       => qr/ZebraNet PrintServer/,
        description => { function => 'FusionInventory::Agent::::Tools::Hardware::Zebranet::getDescription' },
        vendor      => { value    => 'Zebranet' },
        type        => { value    => 'PRINTER' }
    },
    {
        match       => qr/ZebraNet Wired PS/,
        description => { function => 'FusionInventory::Agent::Tools::Hardware::Zebranet::getDescription' },
        vendor      => { value    => 'Zebranet' },
    },
);

my @trunk_ports_rules = (
    {
        match  => qr/Nortel/,
        module => 'FusionInventory::Agent::Tools::Hardware::Nortel',
    },
    {
        match  => qr/.*/,
        module => 'FusionInventory::Agent::Tools::Hardware::Generic',
    },
);

my @connected_devices_rules = (
    {
        match  => qr/Nortel/,
        module => 'FusionInventory::Agent::Tools::Hardware::Nortel',
    },
    {
        match  => qr/.*/,
        module => 'FusionInventory::Agent::Tools::Hardware::Generic',
    },
);

my @connected_devices_mac_addresses_rules = (
    {
        match    => qr/Cisco/,
        module   => 'FusionInventory::Agent::Tools::Hardware::Cisco',
    },
    {
        match    => qr/Juniper/,
        module   => 'FusionInventory::Agent::Tools::Hardware::Juniper',
    },
    {
        match    => qr/.*/,
        module   => 'FusionInventory::Agent::Tools::Hardware::Generic',
    },
);

my @specific_cleanup_rules = (
    {
        match    => qr/3Com IntelliJack/,
        module   => 'FusionInventory::Agent::Tools::Hardware::3Com',
        function => 'RewritePortOf225'
    },
);

# generic properties
my %properties = (
    MAC          => 'macaddr',
    CPU          => 'cpu',
    LOCATION     => 'location',
    FIRMWARE     => 'firmware',
    CONTACT      => 'contact',
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

sub getDeviceBaseInfo {
    my ($snmp) = @_;

    # retrieve sysdescr value, as it is our primary identification key
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0'); # SNMPv2-MIB::sysDescr.0

    # failure eithers means a network or a credential issue
    return unless $sysdescr;

    my %device;

    # first heuristic:
    # try to deduce manufacturer and type from first sysdescr word
    my ($first_word) = $sysdescr =~ /^(\S+)/;
    my $keyword = $hardware_keywords{lc($first_word)};

    if ($keyword) {
        $device{MANUFACTURER} = $keyword->{vendor};
        $device{TYPE}         = $keyword->{type};
    }

    # second heuristic:
    # try to deduce manufacturer, type and a more specific identification key
    # from a set of custom rules matched against full sysdescr value
    # the first matching rule wins
    if ($snmp) {
        foreach my $rule (@hardware_rules) {
            next unless $sysdescr =~ $rule->{match};
            $device{MANUFACTURER} = _apply_rule($rule->{vendor}, $snmp);
            $device{TYPE}         = _apply_rule($rule->{type}, $snmp);
            $device{DESCRIPTION}  = _apply_rule($rule->{description}, $snmp);
            last;
        }
    }

    # use sysdescr as default identification key
    $device{DESCRIPTION}  = $sysdescr if !$device{DESCRIPTION};

    # SNMPv2-MIB::sysName.0
    $device{SNMPHOSTNAME} = $snmp->get('.1.3.6.1.2.1.1.5.0');

    return %device;
}

sub _getSerial {
    my ($snmp, $model) = @_;

    return unless $model->{SERIAL};
    return $snmp->getSerialNumber($model->{SERIAL});
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $mac_oid =
        $model->{MAC} ||
        ".1.3.6.1.2.1.17.1.1.0"; # SNMPv2-SMI::mib-2.17.1.1.0
    my $dynmac_oid =
        $model->{DYNMAC} ||
        ".1.3.6.1.2.1.2.2.1.6";  # IF-MIB::ifPhysAddress

    my $address = $snmp->getMacAddress($mac_oid);

    if (!$address || $address !~ /^$mac_address_pattern$/) {
        my $macs = $snmp->walkMacAddresses($dynmac_oid);
        foreach my $value (values %{$macs}) {
            next if !$value;
            next if $value eq '0:0:0:0:0:0';
            next if $value eq '00:00:00:00:00:00';
            $address = $value;
        }
    }

    return $address;
}

sub getDeviceInfo {
     my ($snmp, $dictionary) = @_;

    # the device is initialized with basic information
    # deduced from its sysdescr
    my %device = getDeviceBaseInfo($snmp);

    # then, we try to get a matching model from the dictionary,
    # using its current description as identification key
    my $model = $dictionary ?
        $dictionary->getModel($device{DESCRIPTION}) : undef;

    if ($model) {
        # if found, we complete the device with model-defined mappings
        $device{MANUFACTURER} = $model->{MANUFACTURER}
            if $model->{MANUFACTURER};
        $device{TYPE}         =
            $model->{TYPE} == 1 ? 'COMPUTER'   :
            $model->{TYPE} == 2 ? 'NETWORKING' :
            $model->{TYPE} == 3 ? 'PRINTER'    :
                                  undef
            if $model->{TYPE};

        $device{MAC}       = _getMacAddress($snmp, $model);
        $device{SERIAL}    = _getSerial($snmp, $model);
        $device{MODELSNMP} = $model->{MODELSNMP};
        $device{FIRMWARE}  = $model->{FIRMWARE};
        $device{MODEL}     = $model->{MODEL};
    } else {
        # otherwise, we fallback on default mappings
        $device{MAC} = _getMacAddress($snmp);
    }

    return %device;
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

sub _setTrunkPorts {
    my ($description, $results, $ports) = @_;

    foreach my $rule (@trunk_ports_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setTrunkPorts',
            params   => { results => $results, ports => $ports },
            load     => 1
        );

        last;
    }

}
sub _setConnectedDevices {
    my ($description, $results, $ports, $walks) = @_;

    foreach my $rule (@connected_devices_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
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

    foreach my $rule (@connected_devices_mac_addresses_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
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
    my ($description, $results, $ports) = @_;

    foreach my $rule (@specific_cleanup_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => $rule->{function},
            params   => {
                results => $results,
                ports   => $ports
            },
            load     => 1
        );

        last;
    }
}

sub getDeviceFullInfo {
    my (%params) = @_;

    my $credentials = $params{credentials};
    my $model       = $params{model};
    my $device      = $params{device};
    my $logger      = $params{logget};

    my $snmp;
    if ($device->{FILE}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{FILE}
            );
        };
        if ($EVAL_ERROR) {
            $logger->error("Unable to create SNMP session for $device->{FILE}: $EVAL_ERROR");
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
            $logger->error("Unable to create SNMP session for $device->{IP}: $EVAL_ERROR");
            return;
        }
    }

    # first, let's retrieve basic device informations
    my %info = getDeviceBaseInfo($snmp);

    if (!%info) {
        return {
            ERROR => {
                ID      => $device->{ID},
                TYPE    => $device->{TYPE},
                MESSAGE => "No response from remote host"
            }
        };
    }

    # unfortunatly, some elements differs between discovery
    # and inventory response
    delete $info{DESCRIPTION};
    delete $info{SNMPHOSTNAME};

    # automatically extend model for cartridge support
    if ($device->{TYPE} eq "PRINTER") {
        foreach my $variable (values %{$model->{GET}}) {
            my $object = $variable->{OBJECT};
            next unless $object;
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
        next unless $variable->{OBJECT};
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
            %info
        }
    };

    _setGenericProperties(
        results => $results,
        device  => $datadevice,
        walks   => $model->{WALK}
    );

    _setPrinterProperties(
        results => $results,
        device  => $datadevice,
    ) if $device->{TYPE} eq 'PRINTER';

    _setNetworkingProperties(
        results     => $results,
        device      => $datadevice,
        walks       => $model->{WALK},
        host        => $device->{IP},
        credentials => $credentials,
        logger      => $logger
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
    my (%params) = @_;

    my $results = $params{results};
    my $device  = $params{device};

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
        $device->{INFO}->{IPS}->{IP} =  [
            sort values %{$results->{ipAdEntAddr}}
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
    my (%params) = @_;

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
    my (%params) = @_;

    my $results = $params{results};
    my $device  = $params{device};
    my $walks   = $params{walks};
    my $logger  = $params{logger};

    $device->{INFO}->{MODEL} = $results->{entPhysicalModelName};

    my $comments = $device->{INFO}->{DESCRIPTION} || $device->{INFO}->{COMMENTS};
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
                $logger->error(
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

FusionInventory::Agent::Tools::Hardware - Hardware-related functions

=head1 DESCRIPTION

This module provides some hardware-related functions.

=head1 FUNCTIONS

=head2 getDeviceBaseInfo($snmp)

return a minimal set of information for a device through SNMP, according to a
set of rules hardcoded in the agent.

=head2 getDeviceInfo($snmp, $dictionnary)

return a minimal set of information for a device through SNMP, according to a
set of rules hardcoded in the agent and the usage of an additional knowledge
base, the dictionary.

=head2 setConnectedDevicesMacAddresses($description, $results, $ports, $walks, $vlan_id)

set mac addresses of connected devices.

=over

=item * description: device identification key

=item * results: raw values collected through SNMP

=item * ports: device ports list

=item * walks: model walk branch

=item * vlan_id: VLAN identifier

=back

=head2 setConnectedDevices($description, $results, $ports, $walks)

Set connected devices using CDP if available, LLDP otherwise.

=over

=item * description: device identification key

=item * results: raw values collected through SNMP

=item * ports: device ports list

=item * walks: model walk branch

=back

=head2 setTrunkPorts($description, $results, $ports)

Set trunk flag on ports needing it.

=over

=item * description: device identification key

=item * results: raw values collected through SNMP

=item * ports: device ports list

=back

=head2 performSpecificCleanup($description, $results, $ports)

Perform device-specific miscaelanous cleanups

=over

=item * description: device identification key

=item * results: raw values collected through SNMP

=item * ports: device ports list

=back
