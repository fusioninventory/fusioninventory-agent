package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use List::Util qw(first);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools; # runFunction
use FusionInventory::Agent::Tools::Network;

our @EXPORT = qw(
    getDeviceBaseInfo
    getDeviceInfo
    getDeviceFullInfo
    loadModel
    getCanonicalSerialNumber
    getCanonicalMacAddress
    getCanonicalMemory
    getElement
    getElements
);

my %types = (
    1 => 'COMPUTER',
    2 => 'NETWORKING',
    3 => 'PRINTER'
);

# http://www.iana.org/assignments/enterprise-numbers/enterprise-numbers
my %sysobjectid_vendors = (
    2     => { vendor => 'IBM',             type => 'COMPUTER'   },
    9     => { vendor => 'Cisco',           type => 'NETWORKING' },
    11    => { vendor => 'Hewlett-Packard'                       },
    23    => { vendor => 'Novell',          type => 'COMPUTER'   },
    36    => { vendor => 'DEC',             type => 'COMPUTER'   },
    42    => { vendor => 'Sun',             type => 'COMPUTER'   },
    43    => { vendor => '3Com',            type => 'NETWORKING' },
    45    => { vendor => 'Nortel',          type => 'NETWORKING' },
    63    => { vendor => 'Apple',                                },
    171   => { vendor => 'D-Link',          type => 'NETWORKING' },
    186   => { vendor => 'Toshiba',         type => 'PRINTER'    },
    207   => { vendor => 'Allied',          type => 'NETWORKING' },
    236   => { vendor => 'Samsung',         type => 'PRINTER'    },
    253   => { vendor => 'Xerox',           type => 'PRINTER'    },
    289   => { vendor => 'Brocade',         type => 'NETWORKING' },
    367   => { vendor => 'Ricoh',           type => 'PRINTER'    },
    368   => { vendor => 'Axis',            type => 'NETWORKING' },
    534   => { vendor => 'Eaton',           type => 'NETWORKING' },
    637   => { vendor => 'Alcatel-Lucent',  type => 'NETWORKING' },
    641   => { vendor => 'Lexmark',         type => 'PRINTER'    },
    674   => { vendor => 'Dell'                                  },
    1139  => { vendor => 'EMC'                                   },
    1248  => { vendor => 'Epson',           type => 'PRINTER'    },
    1347  => { vendor => 'Kyocera',         type => 'PRINTER'    },
    1602  => { vendor => 'Canon',           type => 'PRINTER'    },
    1805  => { vendor => 'Sagem',          type => 'NETWORKING' },
    1872  => { vendor => 'Alteon',          type => 'NETWORKING' },
    1916  => { vendor => 'Extreme',         type => 'NETWORKING' },
    1981  => { vendor => 'EMC'                                   },
    1991  => { vendor => 'Foundry',         type => 'NETWORKING' },
    2385  => { vendor => 'Sharp',           type => 'PRINTER'    },
    2435  => { vendor => 'Brother',         type => 'PRINTER'    },
    2636  => { vendor => 'Juniper',         type => 'NETWORKING' },
    3224  => { vendor => 'NetScreen',       type => 'NETWORKING' },
    3977  => { vendor => 'Broadband',       type => 'NETWORKING' },
    5596  => { vendor => 'Tandberg'                              },
    6486  => { vendor => 'Alcatel',         type => 'NETWORKING' },
    6889  => { vendor => 'Avaya',           type => 'NETWORKING' },
    10418 => { vendor => 'Avocent'                               },
    16885 => { vendor => 'Nortel',          type => 'NETWORKING' },
    18334 => { vendor => 'Konica',          type => 'PRINTER'    },
);

my %sysobjectid_models;

my %sysdescr_first_word = (
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
    'designjet'      => { vendor => 'Hewlett-Packard', type => 'PRINTER'    },
    'deskjet'        => { vendor => 'Hewlett-Packard', type => 'PRINTER'    },
    'd-link'         => { vendor => 'D-Link',          type => 'NETWORKING' },
    'eaton'          => { vendor => 'Eaton',           type => 'NETWORKING' },
    'emc'            => { vendor => 'EMC',                                  },
    'enterasys'      => { vendor => 'Enterasys',       type => 'NETWORKING' },
    'epson'          => { vendor => 'Epson',           type => 'PRINTER'    },
    'extreme'        => { vendor => 'Extrem Networks', type => 'NETWORKING' },
    'extremexos'     => { vendor => 'Extrem Networks', type => 'NETWORKING' },
    'foundry'        => { vendor => 'Foundry',         type => 'NETWORKING' },
    'fuji'           => { vendor => 'Fuji',            type => 'NETWORKING' },
    'h3c'            => { vendor => 'H3C',             type => 'NETWORKING' },
    'hp'             => { vendor => 'Hewlett-Packard', type => 'PRINTER'    },
    'ibm'            => { vendor => 'IBM',             type => 'COMPUTER'   },
    'juniper'        => { vendor => 'Juniper',         type => 'NETWORKING' },
    'konica'         => { vendor => 'Konica',          type => 'PRINTER'    },
    'kyocera'        => { vendor => 'Kyocera',         type => 'PRINTER'    },
    'lexmark'        => { vendor => 'Lexmark',         type => 'PRINTER'    },
    'netapp'         => { vendor => 'NetApp',                               },
    'netgear'        => { vendor => 'NetGear',         type => 'NETWORKING' },
    'nortel'         => { vendor => 'Nortel',          type => 'NETWORKING' },
    'nrg'            => { vendor => 'NRG',             type => 'PRINTER'    },
    'officejet'      => { vendor => 'Hewlett-Packard', type => 'PRINTER'    },
    'oki'            => { vendor => 'OKI',             type => 'PRINTER'    },
    'powerconnect'   => { vendor => 'PowerConnect',    type => 'NETWORKING' },
    'procurve'       => { vendor => 'Hewlett-Packard', type => 'NETWORKING' },
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

my @sysdescr_rules = (
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
        match       => qr/JETDIRECT/,
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
    {
        match       => qr/Nortel Networks$/,
        vendor      => { value    => 'Nortel' },
        type        => { value    => 'NETWORKING' }
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

# common base variables
my %base_variables = (
    MAC          => {
        mapping => 'macaddr'
    },
    CPU          => {
        mapping => 'cpu',
        default => '.1.3.6.1.4.1.9.9.109.1.1.1.1.3.1'
    },
    LOCATION     => {
        mapping => 'location',
        default => '.1.3.6.1.2.1.1.6.0'
    },
    CONTACT      => {
        mapping => 'contact',
        default => '.1.3.6.1.2.1.1.4.0'
    },
    COMMENTS     => {
        mapping => 'comments',
        default => '.1.3.6.1.2.1.1.1.0'
    },
    UPTIME       => {
        mapping => 'uptime',
        default => '.1.3.6.1.2.1.1.3.0'
    },
    SERIAL       => {
        mapping => 'serial'
    },
    NAME         => {
        mapping => 'name',
        default => '.1.3.6.1.2.1.1.5.0'
    },
    MANUFACTURER => {
        mapping => 'enterprise',
        default => '.1.3.6.1.2.1.43.8.2.1.14.1.1'
    },
    OTHERSERIAL  => {
        mapping => 'otherserial'
    },
    MEMORY       => {
        mapping => 'memory',
        default => '.1.3.6.1.2.1.25.2.3.1.5.1'
    },
    RAM          => {
        mapping => 'ram',
        default => '.1.3.6.1.4.1.9.3.6.6.0'
    },
);

# common interface variables
my %interface_variables = (
    IFNUMBER         => {
        mapping => 'ifIndex',
        default => '.1.3.6.1.2.1.2.2.1.1'
    },
    IFDESCR          => {
        mapping => 'ifdescr',
        default => '.1.3.6.1.2.1.2.2.1.2',
    },
    IFNAME           => {
        mapping => 'ifName',
        default => '.1.3.6.1.2.1.2.2.1.2',
    },
    IFTYPE           => {
        mapping => 'ifType',
        default => '.1.3.6.1.2.1.2.2.1.3',
    },
    IFMTU            => {
        mapping => 'ifmtu',
        default => '.1.3.6.1.2.1.2.2.1.4',
    },
    IFSPEED          => {
        mapping => 'ifspeed',
        default => '.1.3.6.1.2.1.2.2.1.5',
    },
    IFSTATUS         => {
        mapping => 'ifstatus',
        default => '.1.3.6.1.2.1.2.2.1.8',
    },
    IFINTERNALSTATUS => {
        mapping => 'ifinternalstatus',
        default => '.1.3.6.1.2.1.2.2.1.7',
    },
    IFLASTCHANGE     => {
        mapping => 'iflastchange',
        default => '.1.3.6.1.2.1.2.2.1.9',
    },
    IFINOCTETS       => {
        mapping => 'ifinoctets',
        default => '.1.3.6.1.2.1.2.2.1.10',
    },
    IFOUTOCTETS      => {
        mapping => 'ifoutoctets',
        default => '.1.3.6.1.2.1.2.2.1.16',
    },
    IFINERRORS       => {
        mapping => 'ifinerrors',
        default => '.1.3.6.1.2.1.2.2.1.14',
    },
    IFOUTERRORS      => {
        mapping => 'ifouterrors',
        default => '.1.3.6.1.2.1.2.2.1.20',
    },
    MAC              => {
        mapping => 'ifPhysAddress',
        default => '.1.3.6.1.2.1.2.2.1.6',
    },
    IFPORTDUPLEX     => {
        mapping => 'portDuplex',
        default => '.1.3.6.1.2.1.10.7.2.1.19'
    },
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
    my ($snmp, $datadir) = @_;

    # retrieve sysdescr value, as it is our primary identification key
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0'); # SNMPv2-MIB::sysDescr.0

    # failure eithers means a network or a credential issue
    return unless $sysdescr;

    my %device;

    # first heuristic:
    # compute manufacturer and type from sysobjectid (SNMPv2-MIB::sysObjectID.0)
    my $sysobjectid = $snmp->get('.1.3.6.1.2.1.1.2.0');
    if ($sysobjectid) {
        my $prefix = qr/(?:
            SNMPv2-SMI::enterprises |
            iso\.3\.6\.1\.4\.1      |
            \.1\.3\.6\.1\.4\.1
        )/x;
        my ($vendor_id, $model_id) =
            $sysobjectid =~ /^ $prefix \. (\d+) (?: \. (.+) )? $/x;
        if ($vendor_id) {
            my $result = $sysobjectid_vendors{$vendor_id};
            if ($result) {
                $result->{model} = _getDeviceModel(
                    vendor  => $result->{vendor},
                    id      => $model_id,
                    datadir => $datadir,
                );
                $device{MANUFACTURER} = $result->{vendor};
                $device{TYPE}         = $result->{type}  if $result->{type};
                $device{MODEL}        = $result->{model} if $result->{model};
            }
        }
    }

    # second heuristic:
    # compute manufacturer and type from first sysdescr word
    my ($first_word) = $sysdescr =~ /^(\S+)/;
    my $result = $sysdescr_first_word{lc($first_word)};

    if ($result) {
        $device{MANUFACTURER} = $result->{vendor};
        $device{TYPE}         = $result->{type} if $result->{type};
    }

    # third heuristic:
    # compute manufacturer, type and a more specific identification key
    # from a list of rules matched against sysdescr value
    # the first matching rule wins
    if ($snmp) {
        foreach my $rule (@sysdescr_rules) {
            next unless $sysdescr =~ $rule->{match};
            $device{MANUFACTURER} = _apply_rule($rule->{vendor}, $snmp)
                if $rule->{vendor};
            $device{TYPE}         = _apply_rule($rule->{type}, $snmp)
                if $rule->{type};
            $device{DESCRIPTION}  = _apply_rule($rule->{description}, $snmp)
                if $rule->{description};
            last;
        }
    }

    # use sysdescr as default identification key
    $device{DESCRIPTION}  = $sysdescr if !$device{DESCRIPTION};

    # SNMPv2-MIB::sysName.0
    my $hostname = $snmp->get('.1.3.6.1.2.1.1.5.0');
    $device{SNMPHOSTNAME} = $hostname if $hostname;

    return %device;
}

sub _getDeviceModel {
    my (%params) = @_;

    return unless $params{id};

    # load vendor-specific database if not already done
    my $vendor = lc($params{vendor});
    $vendor =~ s/ /_/g;
    $sysobjectid_models{$vendor} = _loadDeviceModels(
        file => "$params{datadir}/sysobjectid.$vendor.ids"
    ) if !exists $sysobjectid_models{$vendor};

    return $sysobjectid_models{$vendor}->{$params{id}};
}

sub _loadDeviceModels {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $models;

    while (my $line = <$handle>) {
        chomp $line;
        my ($id, $name) = split(/\t/, $line);
        next unless $id;
        $models->{$id} = $name;
    }

    close $handle;

    return $models;
}

sub _getSerial {
    my ($snmp, $model) = @_;

    return unless $model->{SERIAL};
    return getCanonicalSerialNumber($snmp->get($model->{SERIAL}));
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $mac_oid =
        $model->{MAC} ||
        ".1.3.6.1.2.1.17.1.1.0"; # SNMPv2-SMI::mib-2.17.1.1.0
    my $dynmac_oid =
        $model->{DYNMAC} ||
        ".1.3.6.1.2.1.2.2.1.6";  # IF-MIB::ifPhysAddress

    my $address = getCanonicalMacAddress($snmp->get($mac_oid));

    if (!$address || $address !~ /^$mac_address_pattern$/) {
        my $macs = $snmp->walk($dynmac_oid);
        $address =
            first { $_ ne '00:00:00:00:00:00' }
            map   { getCanonicalMacAddress($_) }
            grep  { $_ }
            sort  { $a cmp $b }
            values %{$macs};
    }

    return $address;
}

sub getDeviceInfo {
    my (%params) = @_;

    my $snmp       = $params{snmp};
    my $dictionary = $params{dictionary};

    # the device is initialized with basic information
    # deduced from its sysdescr
    my %device = getDeviceBaseInfo($snmp, $params{datadir});
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
    my ($description, $snmp, $model, $ports, $logger) = @_;

    foreach my $rule (@trunk_ports_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setTrunkPorts',
            params   => {
                snmp   => $snmp,
                model  => $model,
                ports  => $ports,
                logger => $logger
            },
            load     => 1
        );

        last;
    }

}
sub _setConnectedDevicesInfo {
    my ($description, $snmp, $model, $ports, $logger) = @_;

    foreach my $rule (@connected_devices_rules) {
        next unless $description =~ $rule->{match};

        runFunction(
            module   => $rule->{module},
            function => 'setConnectedDevicesInfo',
            params   => {
                snmp   => $snmp,
                model  => $model,
                ports  => $ports,
                logger => $logger
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
    my $logger = $params{logger};

    # first, let's retrieve basic device informations
    my %info = getDeviceBaseInfo($snmp, $params{datadir});
    return unless %info;

    # unfortunatly, some elements differs between discovery
    # and inventory response
    delete $info{DESCRIPTION};
    delete $info{SNMPHOSTNAME};

    # device ID is set from the server request
    $info{ID} = $params{id};

    # device TYPE is set either:
    # - from the server request,
    # - from the model type
    # - from initial identification
    $info{TYPE} =
            $params{type} ? $params{type}          :
            $model        ? $types{$model->{TYPE}} :
                            $info{TYPE}            ;

    # second, use results to build the object
    my $device = { INFO => \%info };

    _setGenericProperties(
        device => $device,
        snmp   => $snmp,
        model  => $model,
        logger => $logger
    );

    _setPrinterProperties(
        device  => $device,
        snmp   => $snmp,
        model  => $model,
        logger => $logger
    ) if $info{TYPE} && $info{TYPE} eq 'PRINTER';

    _setNetworkingProperties(
        device      => $device,
        snmp        => $snmp,
        model       => $model,
        logger      => $logger
    ) if $info{TYPE} && $info{TYPE} eq 'NETWORKING';

    # convert ports hashref to an arrayref, sorted by interface number
    my $ports = $device->{PORTS}->{PORT};
    if ($ports && %$ports) {
        $device->{PORTS}->{PORT} = [
            map { $ports->{$_} }
            sort { $a <=> $b }
            keys %{$ports}
        ];
    } else {
        delete $device->{PORTS};
    }

    return $device;
}

sub _setGenericProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logger};

    my $firmware;
    if ($model->{oids}->{firmware}) {
        $firmware = $snmp->get($model->{oids}->{firmware});
    } else {
        my @parts;
        if ($model->{oids}->{firmware1}) {
            my $firmware1 = $snmp->get($model->{oids}->{firmware1});
            push @parts, $firmware1 if $firmware1;
        }
        if ($model->{oids}->{firmware2}) {
            my $firmware2 = $snmp->get($model->{oids}->{firmware2});
            push @parts, $firmware2 if $firmware2;
        }
        $firmware = join(' ', @parts) if @parts;
    }
    $device->{INFO}->{FIRMWARE} = $firmware if $firmware;

    foreach my $key (keys %base_variables) {
        # don't overwrite known values
        next if $device->{INFO}->{$key};

        # skip undefined variable
        my $variable = $base_variables{$key};
        my $oid = $model->{oids}->{$variable->{mapping}} ||
                  $variable->{default};
        next unless $oid;

        my $raw_value = $snmp->get($oid);
        next unless defined $raw_value;
        my $value =
            $key eq 'NAME'        ? hex2char($raw_value)                           :
            $key eq 'LOCATION'    ? hex2char($raw_value)                           :
            $key eq 'SERIAL'      ? getCanonicalSerialNumber(hex2char($raw_value)) :
            # OTHERSERIAL can be either:
            #  - a number in hex
            #  - a number
            #  - a string in hex
            # if we use a number as a string, we can garbage char. For example for:
            #  - 0x0115
            #  - 0xfde8
            $key eq 'OTHERSERIAL' ? getCanonicalSerialNumber($raw_value) :
            $key eq 'RAM'         ? getCanonicalMemory($raw_value)       :
            $key eq 'MEMORY'      ? getCanonicalMemory($raw_value)       :
            $key eq 'MAC'         ? getCanonicalMacAddress($raw_value)   :
                                    hex2char($raw_value)                 ;

        $device->{INFO}->{$key} = $value if defined $value;
    }

    if ($model->{oids}->{ipAdEntAddr}) {
        my $results = $snmp->walk($model->{oids}->{ipAdEntAddr});
        $device->{INFO}->{IPS}->{IP} =  [
            sort values %{$results}
        ] if $results;
    }

    # ports is a sparse list of network ports, indexed by native port number
    my $ports;

    foreach my $key (keys %interface_variables) {
        my $variable = $interface_variables{$key};
        my $oid = $model->{oids}->{$variable->{mapping}} ||
                  $variable->{default};
        next unless $oid;
        my $results = $snmp->walk($oid);
        next unless $results;
        # each result matches the following scheme:
        # $prefix.$i = $value, with $i as port id
        while (my ($suffix, $value) = each %{$results}) {
            if ($key eq 'MAC') {
                $value = getCanonicalMacAddress($value);
            }
            $ports->{$suffix}->{$key} = $value if defined $value;
        }
    }

    if ($model->{oids}->{ifaddr}) {
        my $results = $snmp->walk($model->{oids}->{ifaddr});
        # each result matches the following scheme:
        # $prefix.$i.$j.$k.$l = $value
        # with $i.$j.$k.$l as IP address, and $value as port id
        while (my ($suffix, $value) = each %{$results}) {
            next unless $value;
            # safety checks
            if (!$ports->{$value}) {
                $logger->error("non-existing port $value, check ifaddr mapping") if $logger;
                last;
            }
            if ($suffix !~ /^$ip_address_pattern$/) {
                $logger->error("invalid IP address $suffix, check ifaddr mapping") if $logger;
                last;
            }
            $ports->{$value}->{IP} = $suffix;
        }
    }

    $device->{PORTS}->{PORT} = $ports;
}

sub _setPrinterProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};

    $device->{INFO}->{MODEL} = $snmp->get($model->{oids}->{model})
        if !$device->{INFO}->{MODEL};

    # consumable levels
    foreach my $key (keys %printer_cartridges_simple_variables) {
        my $variable = $printer_cartridges_simple_variables{$key};
        next unless $model->{oids}->{$variable};

        my $type_oid = $model->{oids}->{$variable};
        $type_oid =~ s/43.11.1.1.6/43.11.1.1.8/;
        my $type_value  = $snmp->get($type_oid);

        my $level_oid = $model->{oids}->{$variable};
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
        next unless defined $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }

    foreach my $key (keys %printer_cartridges_percent_variables) {
        my $variable     = $printer_cartridges_percent_variables{$key};
        my $max_value    = $snmp->get($model->{oids}->{$variable . 'MAX'});
        my $remain_value = $snmp->get($model->{oids}->{$variable . 'REMAIN'});
        my $value = _getPercentValue($max_value, $remain_value);
        next unless defined $value;
        $device->{CARTRIDGES}->{$key} = $value;
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_variables) {
        my $variable = $printer_pagecounters_variables{$key};
        my $value    = $snmp->get($model->{oids}->{$variable});
        next unless defined $value;
        $device->{PAGECOUNTERS}->{$key} = $value;
    }
}

sub _setNetworkingProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logger};

    $device->{INFO}->{MODEL} = $snmp->get($model->{oids}->{entPhysicalModelName})
        if !$device->{INFO}->{MODEL};

    my $comments = $device->{INFO}->{DESCRIPTION} || $device->{INFO}->{COMMENTS};
    my $ports    = $device->{PORTS}->{PORT};

    my $vlans = $snmp->walk($model->{oids}->{vtpVlanName});

    # Detect VLAN
    if ($model->{oids}->{vmvlan}) {
        my $results = $snmp->walk($model->{oids}->{vmvlan});
        # each result matches either of the following schemes:
        # $prefix.$i.$j = $value, with $j as port id, and $value as vlan id
        # $prefix.$i    = $value, with $i as port id, and $value as vlan id
        foreach my $suffix (sort keys %{$results}) {
            my $port_id = getElement($suffix, -1);
            my $vlan_id = $results->{$suffix};
            my $name    = $vlans->{$vlan_id};

            # safety check
            if (!$ports->{$port_id}) {
                $logger->error("non-existing port $port_id, check vmvlan mapping");
                last;
            }
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

    _setTrunkPorts($comments, $snmp, $model, $ports, $logger);

    _setConnectedDevicesInfo($comments, $snmp, $model, $ports, $logger);

    # ensure module is loaded
    FusionInventory::Agent::Tools::Hardware::Generic->require();

    # check if vlan-specific queries are needed
    my $vlan_query =
        any { $_->{VLAN} }
        @{$model->{WALK}};

    if ($vlan_query) {
        # set connected devices mac addresses for each VLAN,
        # using VLAN-specific SNMP connections
        while (my ($suffix, $value) = each %{$vlans}) {
            my $vlan_id = $suffix;
            $snmp->switch_community("@" . $vlan_id);
            FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
                snmp   => $snmp,
                model  => $model,
                ports  => $ports,
                logger => $logger
            );
        }
    } else {
        # set connected devices mac addresses only once
        FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
            snmp   => $snmp,
            model  => $model,
            ports  => $ports,
            logger => $logger
        );
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

sub loadModel {
    my ($file) = @_;

    my $model = XML::TreePP->new()->parsefile($file)->{model};

    my @get = map {
        {
            OID    => $_->{oid},
            OBJECT => $_->{mapping_name},
            VLAN   => $_->{vlan},
        }
    } grep {
        $_->{dynamicport} == 0
    } grep {
        $_->{mapping_name}
    } @{$model->{oidlist}->{oidobject}};

    my @walk = map {
        {
            OID    => $_->{oid},
            OBJECT => $_->{mapping_name},
            VLAN   => $_->{vlan},
        }
    } grep {
        $_->{dynamicport} == 1
    } grep {
        $_->{mapping_name}
    } @{$model->{oidlist}->{oidobject}};

    my %oids =
        map  { $_->{mapping_name} => $_->{oid} }
        grep { $_->{mapping_name} }
        @{$model->{oidlist}->{oidobject}};

    return {
        ID   => 1,
        NAME => $model->{name},
        TYPE => $model->{type},
        GET  => \@get,
        WALK => \@walk,
        oids => \%oids
    }
}

sub getCanonicalMacAddress {
    my ($value) = @_;

    return unless $value;

    my $r;
    if ($value =~ /$mac_address_pattern/) {
        # this was stored as a string, it just has to be normalized
        $r = join(':', map { sprintf "%02X", hex($_) } split(':', $value));
    } else {
        # this was stored as an hex-string
        # 0xD205A86C26D5 or 0x6001D205A86C26D5
        if ($value =~ /^0x[0-9A-F]{0,4}([0-9A-F]{12})$/i) {
            # value translated by Net::SNMP
            $r = alt2canonical('0x'.$1);
        } else {
            # packed value, onvert from binary to hexadecimal
            $r = getCanonicalMacAddress("0x".unpack 'H*', $value);
        }
    }

    return $r;
}

sub getCanonicalSerialNumber {
    my ($value) = @_;

    return unless $value;

    $value =~ s/\n//g;
    $value =~ s/\r//g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/\.{2,}//g;

    return $value;
}

sub getCanonicalMemory {
    my ($value) = @_;

    if ($value =~ /^(\d+) KBytes$/) {
        return int($1 / 1024);
    } else {
        return int($value / 1024 / 1024);
    }
}

sub getElement {
    my ($oid, $index) = @_;

    my @array = split(/\./, $oid);
    return $array[$index];
}

sub getElements {
    my ($oid, $first, $last) = @_;

    my @array = split(/\./, $oid);
    return @array[$first .. $last];
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

=head2 getDeviceInfo(%params)

return a limited set of information for a device through SNMP, according to a
set of rules hardcoded in the agent and the usage of generic knowledge base,
the dictionary.

=head2 getDeviceFullInfo(%params)

return a full set of information for a device through SNMP, according to a
set of rules hardcoded in the agent and the usage of a device-specific set of mappings, the model.

=head2 getCanonicalSerialNumber($value)

Return a canonical value for a serial number.

=head2 getCanonicalMacAddress($value)

Return a canonical value for a mac address.

=head2 getCanonicalMemory($value)

Return a canonical value for mac address, in bytes.

=head2 getElement($oid, $index)

return the $index element of an oid.

=head2 getElements($oid, $first, $last)

return all elements of index in range $first to $last of an oid.

=head2 loadModel($file)

Load an SNMP description model from given file.
