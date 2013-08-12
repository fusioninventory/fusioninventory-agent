package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);


use FusionInventory::Agent::Tools; # runFunction
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

our @EXPORT = qw(
    getDeviceBaseInfo
    getDeviceInfo
    getDeviceFullInfo
);

my %types = (
    1 => 'COMPUTER',
    2 => 'NETWORKING',
    3 => 'PRINTER'
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

# common base variables
my %base_variables = (
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

# common interface variables
my %interface_variables = (
    IFNUMBER         => 'ifIndex',
    IFDESCR          => 'ifdescr',
    IFNAME           => 'ifName',
    IFTYPE           => 'ifType',
    IFMTU            => 'ifmtu',
    IFSPEED          => 'ifspeed',
    IFSTATUS         => 'ifstatus',
    IFINTERNALSTATUS => 'ifinternalstatus',
    IFLASTCHANGE     => 'iflastchange',
    IFINOCTETS       => 'ifinoctets',
    IFOUTOCTETS      => 'ifoutoctets',
    IFINERRORS       => 'ifinerrors',
    IFOUTERRORS      => 'ifouterrors',
    MAC              => 'ifPhysAddress',
    IFPORTDUPLEX     => 'portDuplex',
);

# printer-specific cartridge simple variables
my %printer_cartridges_simple_variables = (
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

# printer-specific cartridge percent variables
my %printer_cartridges_percent_variables = (
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

# printer-specific page counter variables
my %printer_pagecounters_variables = (
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
    return unless %device;

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
    my ($description, $snmp, $model, $ports) = @_;

    foreach my $rule (@trunk_ports_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setTrunkPorts',
            params   => { snmp => $snmp, model => $model, ports => $ports },
            load     => 1
        );

        last;
    }

}
sub _setConnectedDevices {
    my ($description, $snmp, $model, $ports) = @_;

    foreach my $rule (@connected_devices_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setConnectedDevices',
            params   => { snmp => $snmp, model => $model, ports => $ports },
            load     => 1
        );

        last;
    }
}

sub _setConnectedDevicesMacAddresses {
    my ($description, $snmp, $model, $ports, $vlan_id) = @_;

    foreach my $rule (@connected_devices_mac_addresses_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setConnectedDevicesMacAddresses',
            params   => {
                snmp    => $snmp,
                model   => $model,
                ports   => $ports,
            },
            load     => 1
        );

        last;
    }
}

sub _performSpecificCleanup {
    my ($description, $snmp, $model, $ports) = @_;

    foreach my $rule (@specific_cleanup_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => $rule->{function},
            params   => {
                snmp    => $snmp,
                model   => $model,
                ports   => $ports
            },
            load     => 1
        );

        last;
    }
}

sub getDeviceFullInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logget};
    my $type   = $model ? $types{$model->{TYPE}} : $params{type};

    # first, let's retrieve basic device informations
    my %info = getDeviceBaseInfo($snmp);
    return unless %info;

    # unfortunatly, some elements differs between discovery
    # and inventory response
    delete $info{DESCRIPTION};
    delete $info{SNMPHOSTNAME};

    # second, use results to build the object
    my $device = {
        INFO => {
            ID   => $params{id},
            TYPE => $type,
            %info
        }
    };

    _setGenericProperties(
        device => $device,
        snmp   => $snmp,
        model  => $model
    );

    _setPrinterProperties(
        device  => $device,
        snmp   => $snmp,
        model  => $model
    ) if $type && $type eq 'PRINTER';

    _setNetworkingProperties(
        device      => $device,
        snmp        => $snmp,
        model       => $model,
        logger      => $logger
    ) if $type && $type eq 'NETWORKING';

    # convert ports hashref to an arrayref, sorted by interface number
    my $ports = $device->{PORTS}->{PORT};
    $device->{PORTS}->{PORT} = [
        map { $ports->{$_} }
        sort { $a <=> $b }
        keys %{$ports}
    ];

    return $device;
}

sub _setGenericProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};

    if ($model->{GET}->{firmware1}) {
        $device->{INFO}->{FIRMWARE} = $snmp->get($model->{GET}->{firmware1}->{OID});
    }
    if ($model->{GET}->{firmware2}) {
        if ($device->{INFO}->{FIRMWARE}) {
            $device->{INFO}->{FIRMWARE} .= ' ' ;
        }
        $device->{INFO}->{FIRMWARE} .= $snmp->get($model->{GET}->{firmware2}->{OID});
    }

    foreach my $key (keys %base_variables) {
        # don't overwrite known values
        next if $device->{INFO}->{$key};

        # skip undefined variable
        my $variable = $base_variables{$key};
        next unless $model->{GET}->{$variable};

        my $raw_value = $snmp->get($model->{GET}->{$variable}->{OID});
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

    if ($model->{WALK}->{ipAdEntAddr}) {
        my $results = $snmp->walk($model->{WALK}->{ipAdEntAddr}->{OID});
        $device->{INFO}->{IPS}->{IP} =  [
            sort values %{$results}
        ] if $results;
    }

    # ports is a sparse list of network ports, indexed by native port number
    my $ports;

    foreach my $key (keys %interface_variables) {
        my $variable = $interface_variables{$key};
        my $results = $snmp->walk($model->{WALK}->{$variable}->{OID});
        next unless $results;
        while (my ($oid, $data) = each %{$results}) {
            if ($key eq 'MAC') {
                next unless $data;
                $data = alt2canonical($data);
            }
            $ports->{getLastElement($oid)}->{$key} = $data;
        }
    }

    if ($model->{WALK}->{ifaddr}) {
        my $results = $snmp->walk($model->{WALK}->{ifaddr}->{OID});
        while (my ($oid, $data) = each %{$results}) {
            next unless $data;
            my $address = $oid;
            $address =~ s/$model->{WALK}->{ifaddr}->{OID}//;
            $address =~ s/^.//;
            $ports->{$data}->{IP} = $address;
        }
    }

    $device->{PORTS}->{PORT} = $ports;
}

sub _setPrinterProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};

    $device->{INFO}->{MODEL} = $snmp->get($model->{GET}->{model}->{OID});

    # consumable levels
    foreach my $key (keys %printer_cartridges_simple_variables) {
        my $variable = $printer_cartridges_simple_variables{$key};
        next unless $model->{GET}->{$variable};

        my $type_oid = $model->{GET}->{$variable}->{OID};
        $type_oid =~ s/43.11.1.1.6/43.11.1.1.8/;
        my $type_value  = $snmp->get($type_oid);

        my $level_oid = $model->{GET}->{$variable}->{OID};
        $level_oid =~ s/43.11.1.1.6/43.11.1.1.9/;
        my $level_value = $snmp->get($level_oid);
        next unless defined $level_value;

        my $value =
            $level_value == -3 ?
                100 :
                _getPercentValue(
                    $type_value,
                    $level_value,
                );
        next unless $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }

    foreach my $key (keys %printer_cartridges_percent_variables) {
        my $variable     = $printer_cartridges_percent_variables{$key};
        my $max_value    = $snmp->get($model->{GET}->{$variable . 'MAX'}->{OID});
        my $remain_value = $snmp->get($model->{GET}->{$variable . 'REMAIN'}->{OID});
        my $value = _getPercentValue($max_value, $remain_value);
        next unless $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_variables) {
        my $variable = $printer_pagecounters_variables{$key};
        my $value    = $snmp->get($model->{GET}->{$variable}->{OID});
        $device->{PAGECOUNTERS}->{$key} = $value;
    }
}

sub _setNetworkingProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logger};

    $device->{INFO}->{MODEL} = $snmp->get($model->{GET}->{entPhysicalModelName}->{OID});

    my $comments = $device->{INFO}->{DESCRIPTION} || $device->{INFO}->{COMMENTS};
    my $ports    = $device->{PORTS}->{PORT};

    my $vlans = $snmp->walk($model->{WALK}->{vtpVlanName}->{OID});

    # Detect VLAN
    if ($model->{WALK}->{vmvlan}) {
        my $results = $snmp->walk($model->{WALK}->{vmvlan}->{OID});
        foreach my $oid (sort keys %{$results}) {
            my $port_id  = getLastElement($oid);
            my $vlan_id  = $results->{$oid};
            my $vlan_oid = $model->{WALK}->{vtpVlanName}->{OID} . "." . $vlan_id;
            my $name     = $vlans->{$vlan_oid};
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

    _setTrunkPorts($comments, $snmp, $model, $ports);

    _setConnectedDevices($comments, $snmp, $model, $ports);

    # check if vlan-specific queries are needed
    my $vlan_query =
        any { $_->{VLAN} }
        values %{$model->{WALK}};

    if ($vlan_query) {
        # set connected devices mac addresses for each VLAN,
        # using VLAN-specific SNMP connections
        while (my ($oid, $name) = each %{$vlans}) {
            my $vlan_id = getLastElement($oid);
            $snmp->switch_community("@" . $vlan_id);
            _setConnectedDevicesMacAddresses(
                $comments, $snmp, $model, $ports
            );
        }
    } else {
        # set connected devices mac addresses only once
        _setConnectedDevicesMacAddresses($comments, $snmp, $model, $ports);
    }

    # hardware-specific hacks
    _performSpecificCleanup($comments, $snmp, $model, $ports);
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

=head2 setConnectedDevicesMacAddresses($description, $snmp, $model, $ports, $vlan_id)

set mac addresses of connected devices.

=over

=item * description: device identification key

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=back

=head2 setConnectedDevices($description, $snmp, $model, $ports)

Set connected devices using CDP if available, LLDP otherwise.

=over

=item * description: device identification key

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=back

=head2 setTrunkPorts($description, $snmp, $model, $ports)

Set trunk flag on ports needing it.

=over

=item * description: device identification key

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=back

=head2 performSpecificCleanup($description, $snmp, $model, $ports)

Perform device-specific miscaelanous cleanups

=over

=item * description: device identification key

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=back
