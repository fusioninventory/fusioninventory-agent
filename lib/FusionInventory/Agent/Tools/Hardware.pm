package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use List::Util qw(first);

use FusionInventory::Agent::Tools; # runFunction
use FusionInventory::Agent::Tools::Network;

our @EXPORT = qw(
    getDeviceBaseInfo
    getDeviceInfo
    getDeviceFullInfo
    loadModel
);

my %types = (
    1 => 'COMPUTER',
    2 => 'NETWORKING',
    3 => 'PRINTER',
    4 => 'STORAGE',
    5 => 'POWER',
    6 => 'PHONE',
    7 => 'VIDEO',
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
    1139  => { vendor => 'EMC',             type => 'STORAGE'    },
    1248  => { vendor => 'Epson',           type => 'PRINTER'    },
    1347  => { vendor => 'Kyocera',         type => 'PRINTER'    },
    1602  => { vendor => 'Canon',           type => 'PRINTER'    },
    1805  => { vendor => 'Sagem',           type => 'NETWORKING' },
    1872  => { vendor => 'Alteon',          type => 'NETWORKING' },
    1916  => { vendor => 'Extreme',         type => 'NETWORKING' },
    1981  => { vendor => 'EMC',             type => 'STORAGE'    },
    1991  => { vendor => 'Foundry',         type => 'NETWORKING' },
    2385  => { vendor => 'Sharp',           type => 'PRINTER'    },
    2435  => { vendor => 'Brother',         type => 'PRINTER'    },
    2636  => { vendor => 'Juniper',         type => 'NETWORKING' },
    3224  => { vendor => 'NetScreen',       type => 'NETWORKING' },
    3977  => { vendor => 'Broadband',       type => 'NETWORKING' },
    5596  => { vendor => 'Tandberg',        type => 'VIDEO'      },
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
    'emc'            => { vendor => 'EMC',             type => 'STORAGE'    },
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

# common base variables
my %base_variables = (
    MAC          => {
        mapping => 'macaddr',
        type    => 'mac',
    },
    CPU          => {
        mapping => 'cpu',
        default => '.1.3.6.1.4.1.9.9.109.1.1.1.1.3.1',
        type    => 'count',
    },
    LOCATION     => {
        mapping => 'location',
        default => '.1.3.6.1.2.1.1.6.0',
        type    => 'string',
    },
    CONTACT      => {
        mapping => 'contact',
        default => '.1.3.6.1.2.1.1.4.0',
        type    => 'string',
    },
    COMMENTS     => {
        mapping => 'comments',
        default => '.1.3.6.1.2.1.1.1.0',
        type    => 'string',
    },
    UPTIME       => {
        mapping => 'uptime',
        default => '.1.3.6.1.2.1.1.3.0',
        type    => 'string',
    },
    SERIAL       => {
        mapping => 'serial',
        type    => 'serial',
    },
    NAME         => {
        mapping => 'name',
        default => '.1.3.6.1.2.1.1.5.0',
        type    => 'string',
    },
    MANUFACTURER => {
        mapping => 'enterprise',
        default => '.1.3.6.1.2.1.43.8.2.1.14.1.1',
        type    => 'string',
    },
    OTHERSERIAL  => {
        mapping => 'otherserial',
        type    => 'serial',
    },
    MEMORY       => {
        mapping => 'memory',
        default => '.1.3.6.1.2.1.25.2.3.1.5.1',
        type    => 'memory',
    },
    RAM          => {
        mapping => 'ram',
        default => '.1.3.6.1.4.1.9.3.6.6.0',
        type    => 'memory',
    },
);

# common interface variables
my %interface_variables = (
    IFNUMBER         => {
        mapping => 'ifIndex',
        default => '.1.3.6.1.2.1.2.2.1.1',
        type    => 'none'
    },
    IFDESCR          => {
        mapping => 'ifdescr',
        default => '.1.3.6.1.2.1.2.2.1.2',
        type    => 'string',
    },
    IFNAME           => {
        mapping => 'ifName',
        default => '.1.3.6.1.2.1.2.2.1.2',
        type    => 'string',
    },
    IFTYPE           => {
        mapping => 'ifType',
        default => '.1.3.6.1.2.1.2.2.1.3',
        type    => 'constant',
    },
    IFMTU            => {
        mapping => 'ifmtu',
        default => '.1.3.6.1.2.1.2.2.1.4',
        type    => 'count',
    },
    IFSPEED          => {
        mapping => 'ifspeed',
        default => '.1.3.6.1.2.1.2.2.1.5',
        type    => 'count',
    },
    IFSTATUS         => {
        mapping => 'ifstatus',
        default => '.1.3.6.1.2.1.2.2.1.8',
        type    => 'constant',
    },
    IFINTERNALSTATUS => {
        mapping => 'ifinternalstatus',
        default => '.1.3.6.1.2.1.2.2.1.7',
        type    => 'constant',
    },
    IFLASTCHANGE     => {
        mapping => 'iflastchange',
        default => '.1.3.6.1.2.1.2.2.1.9',
        type    => 'none'
    },
    IFINOCTETS       => {
        mapping => 'ifinoctets',
        default => '.1.3.6.1.2.1.2.2.1.10',
        type    => 'count',
    },
    IFOUTOCTETS      => {
        mapping => 'ifoutoctets',
        default => '.1.3.6.1.2.1.2.2.1.16',
        type    => 'count',
    },
    IFINERRORS       => {
        mapping => 'ifinerrors',
        default => '.1.3.6.1.2.1.2.2.1.14',
        type    => 'count',
    },
    IFOUTERRORS      => {
        mapping => 'ifouterrors',
        default => '.1.3.6.1.2.1.2.2.1.20',
        type    => 'count',
    },
    MAC              => {
        mapping => 'ifPhysAddress',
        default => '.1.3.6.1.2.1.2.2.1.6',
        type    => 'mac',
    },
    IFPORTDUPLEX     => {
        mapping => 'portDuplex',
        default => '.1.3.6.1.2.1.10.7.2.1.19',
        type    => 'constant',
    },
    IFALIAS          => {
        mapping => 'ifAlias',
        default => '.1.3.6.1.2.1.31.1.1.1.18',
        type    => 'string',
    },
);

my @consumable_type_rules = (
    {
        match => qr/cyan/i,
        value => 'cyan'
    },
    {
        match => qr/magenta/i,
        value => 'magenta'
    },
    {
        match => qr/(black|noir)/i,
        value => 'black'
    },
    {
        match => qr/(yellow|jaune)/i,
        value => 'yellow'
    },
    {
        match => qr/waste/i,
        value => 'waste'
    },
    {
        match => qr/maintenance/i,
        value => 'maintenance'
    },
);

my @consumable_subtype_rules = (
    {
        match => qr/toner/i,
        value => 'toner'
    },
    {
        match => qr/drum/i,
        value => 'drum'
    },
    {
        match => qr/ink/i,
        value => 'cartridge'
    },
);

my %consumable_variables_from_type = (
    cyan => {
        toner     => 'TONERCYAN',
        drum      => 'DRUMCYAN',
        cartridge => 'CARTRIDGECYAN',
    },
    magenta     => {
        toner     => 'TONERMAGENTA',
        drum      => 'DRUMMAGENTA',
        cartridge => 'CARTRIDGEMAGENTA',
    },
    black     => {
        toner     => 'TONERBLACK',
        drum      => 'DRUMBLACK',
        cartridge => 'CARTRIDGEBLACK',
    },
    yellow     => {
        toner     => 'TONERYELLOW',
        drum      => 'DRUMYELLOW',
        cartridge => 'CARTRIDGEYELLOW',
    },
    waste       => 'WASTETONER',
    maintenance => 'MAINTENANCEKIT',
);

my %consumable_variables_from_mappings = (
    tonerblack            => 'TONERBLACK',
    tonerblack2           => 'TONERBLACK2',
    tonercyan             => 'TONERCYAN',
    tonermagenta          => 'TONERMAGENTA',
    toneryellow           => 'TONERYELLOW',
    wastetoner            => 'WASTETONER',
    cartridgeblack        => 'CARTRIDGEBLACK',
    cartridgeblackphoto   => 'CARTRIDGEBLACKPHOTO',
    cartridgecyan         => 'CARTRIDGECYAN',
    cartridgecyanlight    => 'CARTRIDGECYANLIGHT',
    cartridgemagenta      => 'CARTRIDGEMAGENTA',
    cartridgemagentalight => 'CARTRIDGEMAGENTALIGHT',
    cartridgeyellow       => 'CARTRIDGEYELLOW',
    maintenancekit        => 'MAINTENANCEKIT',
    drumblack             => 'DRUMBLACK',
    drumcyan              => 'DRUMCYAN',
    drummagenta           => 'DRUMMAGENTA',
    drumyellow            => 'DRUMYELLOW',
);

# printer-specific page counter variables
my %printer_pagecounters_variables = (
    TOTAL      => {
        mapping => 'pagecountertotalpages',
        default => '.1.3.6.1.2.1.43.10.2.1.4.1.1'
    },
    BLACK      => { mapping => 'pagecounterblackpages'       },
    COLOR      => { mapping => 'pagecountercolorpages'       },
    RECTOVERSO => { mapping => 'pagecounterrectoversopages'  },
    SCANNED    => { mapping => 'pagecounterscannedpages'     },
    PRINTTOTAL => { mapping => 'pagecountertotalpages_print' },
    PRINTBLACK => { mapping => 'pagecounterblackpages_print' },
    PRINTCOLOR => { mapping => 'pagecountercolorpages_print' },
    COPYTOTAL  => { mapping => 'pagecountertotalpages_copy'  },
    COPYBLACK  => { mapping => 'pagecounterblackpages_copy'  },
    COPYCOLOR  => { mapping => 'pagecountercolorpages_copy'  },
    FAXTOTAL   => { mapping => 'pagecountertotalpages_fax'   },
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
    return _getCanonicalSerialNumber($snmp->get($model->{SERIAL}));
}

sub _getMacAddress {
    my ($snmp, $model) = @_;

    my $mac_oid =
        $model->{MAC} ||
        ".1.3.6.1.2.1.17.1.1.0"; # SNMPv2-SMI::mib-2.17.1.1.0
    my $dynmac_oid =
        $model->{DYNMAC} ||
        ".1.3.6.1.2.1.2.2.1.6";  # IF-MIB::ifPhysAddress

    my $address = _getCanonicalMacAddress($snmp->get($mac_oid));

    if (!$address || $address !~ /^$mac_address_pattern$/) {
        my $macs = $snmp->walk($dynmac_oid);
        $address =
            first { $_ ne '00:00:00:00:00:00' }
            map   { _getCanonicalMacAddress($_) }
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
            $params{type}            ? $params{type}          :
            $model && $model->{TYPE} ? $types{$model->{TYPE}} :
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

        my $type = $variable->{type};
        my $value =
            $type eq 'mac'    ? _getCanonicalMacAddress($raw_value)   :
            $type eq 'memory' ? _getCanonicalMemory($raw_value)       :
            $type eq 'serial' ? _getCanonicalSerialNumber($raw_value) :
            $type eq 'string' ? _getCanonicalString($raw_value)       :
            $type eq 'count'  ? _getCanonicalCount($raw_value)        :
                                $raw_value;

        $device->{INFO}->{$key} = $value if defined $value;
    }

    my $results = $snmp->walk(
        $model->{oids}->{ipAdEntAddr} || '.1.3.6.1.2.1.4.20.1.1'
    );
    $device->{INFO}->{IPS}->{IP} =  [
        sort values %{$results}
    ] if $results;

    # ports is a sparse list of network ports, indexed by native port number
    my $ports;

    foreach my $key (keys %interface_variables) {
        my $variable = $interface_variables{$key};
        my $oid = $model->{oids}->{$variable->{mapping}} ||
                  $variable->{default};
        next unless $oid;
        my $results = $snmp->walk($oid);
        next unless $results;

        my $type = $variable->{type};
        # each result matches the following scheme:
        # $prefix.$i = $value, with $i as port id
        while (my ($suffix, $raw_value) = each %{$results}) {
            my $value =
                $type eq 'mac'      ? _getCanonicalMacAddress($raw_value) :
                $type eq 'constant' ? _getCanonicalConstant($raw_value)   :
                $type eq 'string'   ? _getCanonicalString($raw_value)     :
                $type eq 'count'    ? _getCanonicalCount($raw_value)      :
                                      $raw_value;
            $ports->{$suffix}->{$key} = $value if defined $value;
        }
    }

    $results = $snmp->walk(
        $model->{oids}->{ifaddr} || '.1.3.6.1.2.1.4.20.1.2'
    );
    # each result matches the following scheme:
    # $prefix.$i.$j.$k.$l = $value
    # with $i.$j.$k.$l as IP address, and $value as port id
    foreach my $suffix (sort keys %{$results}) {
        my $value = $results->{$suffix};
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

    $device->{PORTS}->{PORT} = $ports;
}

sub _setPrinterProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logger};

    if (!$device->{INFO}->{MODEL}) {
        $device->{INFO}->{MODEL} = $snmp->get(
            $model->{oids}->{model} || '.1.3.6.1.2.1.25.3.2.1.3.1'
        );
    }

    # consumable levels

    # index model-provided mappings
    my %consumable_variables_from_oids;
    foreach my $key (sort keys %consumable_variables_from_mappings) {
        next unless $model->{oids}->{$key};
        my $variable = $consumable_variables_from_mappings{$key};
        $consumable_variables_from_oids{$model->{oids}->{$key}} = $variable;
    }

    # enumerate consumables
    foreach my $index (1 .. 10) {
        my $description_oid = '.1.3.6.1.2.1.43.11.1.1.6.1.' . $index;
        my $description = hex2char($snmp->get($description_oid));
        last unless $description;

        my $max_oid     = '.1.3.6.1.2.1.43.11.1.1.8.1.' . $index;
        my $current_oid = '.1.3.6.1.2.1.43.11.1.1.9.1.' . $index;
        my $max     = $snmp->get($max_oid);
        my $current = $snmp->get($current_oid);
        next unless defined $max and defined $current;

        my $value = $current == -3 ?
            100 : _getPercentValue($max, $current);
        next unless defined $value;

        # consumable identification
        my $variable =
            $consumable_variables_from_oids{$description_oid} ||
            _getConsumableVariableFromDescription($description);

        next unless $variable;

        $device->{CARTRIDGES}->{$variable} = $value;
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_variables) {
        my $variable = $printer_pagecounters_variables{$key};
        my $oid = $model->{oids}->{$variable->{mapping}} ||
                  $variable->{default};
        my $value = $snmp->get($oid);
        next unless defined $value;
        if (!_isInteger($value)) {
            $logger->error("incorrect counter value $value, check $variable->{mapping} mapping") if $logger;
            next;
        }
        $device->{PAGECOUNTERS}->{$key} = $value;
    }
}

sub _getConsumableVariableFromDescription {
    my ($description) = @_;

    # find type
    my $type;
    foreach my $rule (@consumable_type_rules) {
        next unless $description =~ $rule->{match};
        $type = $rule->{value};
        last;
    }
    return unless $type;

    my $result = $consumable_variables_from_type{$type};
    # for waste and toner, type is enough
    return $result unless ref $result;

    # otherwise, let's find subtype

    my $subtype;
    foreach my $rule (@consumable_subtype_rules) {
        next unless $description =~ $rule->{match};
        $subtype = $rule->{value};
        last;
    }
    return unless $subtype;

    return $consumable_variables_from_type{$type}->{$subtype};
}

sub _setNetworkingProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $logger = $params{logger};

    if (!$device->{INFO}->{MODEL}) {
        $device->{INFO}->{MODEL} = $snmp->get(
            $model->{oids}->{entPhysicalModelName} || '.1.3.6.1.2.1.47.1.1.1.1.13.1'
        )
    }

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
            my $port_id = _getElement($suffix, -1);
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

    _setTrunkPorts(
        snmp   => $snmp,
        model  => $model,
        ports  => $ports,
        logger => $logger
    );

    _setConnectedDevicesInfo(
        snmp   => $snmp,
        model  => $model,
        ports  => $ports,
        logger => $logger
    );

    _setAssociatedMacAddresses(
        snmp   => $snmp,
        model  => $model,
        ports  => $ports,
        logger => $logger
    );
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

    my %oids =
        map  { $_->{mapping_name} => $_->{oid} }
        grep { $_->{mapping_name} }
        @{$model->{oidlist}->{oidobject}};

    return {
        ID   => 1,
        NAME => $model->{name},
        TYPE => $model->{type},
        oids => \%oids
    }
}

sub _getCanonicalMacAddress {
    my ($value) = @_;

    return unless $value;

    my $result;
    if ($value =~ /$mac_address_pattern/) {
        # this was stored as a string, it just has to be normalized
        $result = sprintf
            "%02x:%02x:%02x:%02x:%02x:%02x",
            map { hex($_) } split(':', $value);
    } else {
        # this was stored as an hex-string
        # 0xD205A86C26D5 or 0x6001D205A86C26D5
        if ($value =~ /^0x[0-9A-F]{0,4}([0-9A-F]{12})$/i) {
            # value translated by Net::SNMP
            $result = alt2canonical('0x'.$1);
        } else {
            # packed value, onvert from binary to hexadecimal
            $result = unpack 'H*', $value;
        }
    }

    return lc($result);
}

sub _getCanonicalString {
    my ($value) = @_;

    $value = hex2char($value);
    return unless $value;

    $value =~ s/^["']//;
    $value =~ s/["']$//;
    return unless $value;

    return $value;
}

sub _getCanonicalSerialNumber {
    my ($value) = @_;

    $value = hex2char($value);
    return unless $value;

    $value =~ s/[[:^print:]]//g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/\.{2,}//g;
    return unless $value;

    return $value;
}

sub _getCanonicalMemory {
    my ($value) = @_;

    if ($value =~ /^(\d+) KBytes$/) {
        return int($1 / 1024);
    } else {
        return int($value / 1024 / 1024);
    }
}

sub _getCanonicalConstant {
    my ($value) = @_;

    return $value if _isInteger($value);
    return $1 if $value =~ /\((\d+)\)$/;
}

sub _getCanonicalCount {
    my ($value) = @_;

    return _isInteger($value) ? $value  : undef;
}

sub _getElement {
    my ($oid, $index) = @_;

    my @array = split(/\./, $oid);
    return $array[$index];
}

sub _getElements {
    my ($oid, $first, $last) = @_;

    my @array = split(/\./, $oid);
    return @array[$first .. $last];
}

sub _setAssociatedMacAddresses {
    my (%params) = @_;

    my $mac_addresses = _getAssociatedMacAddresses(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $mac_addresses;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$mac_addresses) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check dot1d* mappings")
                if $logger;
            last;
        }

        my $port = $ports->{$port_id};

        # connected device has already been identified through CDP/LLDP
        next if
            exists $port->{CONNECTIONS} &&
            exists $port->{CONNECTIONS}->{CDP} &&
            $port->{CONNECTIONS}->{CDP};

        # filter out the port own mac address, if known
        my $addresses = $mac_addresses->{$port_id};
        if (exists $port->{MAC}) {
            $addresses = [ grep { $_ ne $port->{MAC} } @$addresses ];
        }

        next unless @$addresses;

        $port->{CONNECTIONS}->{CONNECTION}->{MAC} = $addresses;
    }
}

sub _getAssociatedMacAddresses {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $dot1dTpFdbPort       = $snmp->walk(
        $model->{oids}->{dot1dTpFdbPort}       || '.1.3.6.1.2.1.17.4.3.1.2'
    );
    my $dot1dBasePortIfIndex = $snmp->walk(
        $model->{oids}->{dot1dBasePortIfIndex} || '.1.3.6.1.2.1.17.1.4.1.2'
    );

    foreach my $suffix (sort keys %{$dot1dTpFdbPort}) {
        my $port_id      = $dot1dTpFdbPort->{$suffix};
        my $interface_id = $dot1dBasePortIfIndex->{$port_id};
        next unless defined $interface_id;

        push @{$results->{$interface_id}},
            sprintf "%02x:%02x:%02x:%02x:%02x:%02x", split(/\./, $suffix)
    }

    return $results;
}

sub _setConnectedDevicesInfo {
    my (%params) = @_;

    my $info =
        _getConnectedDevicesInfoCDP(%params) ||
        _getConnectedDevicesInfoLLDP(%params);
    return unless $info;

    my $logger = $params{logger};
    my $ports  = $params{ports};

    foreach my $port_id (keys %$info) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error(
                "non-existing port $port_id, check CDP/LLDP mappings"
            ) if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $info->{$port_id}
        };
    }
}

sub _getConnectedDevicesInfoCDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $cdpCacheAddress    = $snmp->walk(
        $model->{oids}->{cdpCacheAddress}    || '.1.3.6.1.4.1.9.9.23.1.2.1.1.4'
    );
    my $cdpCacheVersion    = $snmp->walk(
        $model->{oids}->{cdpCacheVersion}    || '.1.3.6.1.4.1.9.9.23.1.2.1.1.5'
    );
    my $cdpCacheDeviceId   = $snmp->walk(
        $model->{oids}->{cdpCacheDeviceId}   || '.1.3.6.1.4.1.9.9.23.1.2.1.1.6'
    );
    my $cdpCacheDevicePort = $snmp->walk(
        $model->{oids}->{cdpCacheDevicePort} || '.1.3.6.1.4.1.9.9.23.1.2.1.1.7'
    );
    my $cdpCachePlatform   = $snmp->walk(
        $model->{oids}->{cdpCachePlatform}   || '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    );

    # each cdp variable matches the following scheme:
    # $prefix.x.y = $value
    # whereas x is the port number

    while (my ($suffix, $ip) = each %{$cdpCacheAddress}) {
        my $port_id = _getElement($suffix, -2);
        $ip = hex2canonical($ip);
        next if $ip eq '0.0.0.0';

        my $connection = {
            IP       => $ip,
            IFDESCR  => $cdpCacheDevicePort->{$suffix},
            SYSDESCR => $cdpCacheVersion->{$suffix},
            SYSNAME  => $cdpCacheDeviceId->{$suffix},
            MODEL    => $cdpCachePlatform->{$suffix}
        };

        if ($connection->{SYSNAME} =~ /^SIP([A-F0-9a-f]*)$/) {
            $connection->{MAC} = lc(alt2canonical("0x".$1));
        }

        next if !$connection->{SYSDESCR} || !$connection->{MODEL};

        $results->{$port_id} = $connection;
    }

    return $results;
}

sub _getConnectedDevicesInfoLLDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $lldpRemChassisId = $snmp->walk(
        $model->{oids}->{lldpRemChassisId} || '.1.0.8802.1.1.2.1.4.1.1.5'
    );
    my $lldpRemPortId    = $snmp->walk(
        $model->{oids}->{lldpRemPortId}    || '.1.0.8802.1.1.2.1.4.1.1.7'
    );
    my $lldpRemPortDesc  = $snmp->walk(
        $model->{oids}->{lldpRemPortDesc}  || '.1.0.8802.1.1.2.1.4.1.1.8'
    );
    my $lldpRemSysName   = $snmp->walk(
        $model->{oids}->{lldpRemSysName}   || '.1.0.8802.1.1.2.1.4.1.1.9'
    );
    my $lldpRemSysDesc   = $snmp->walk(
        $model->{oids}->{lldpRemSysDesc}   || '.1.0.8802.1.1.2.1.4.1.1.10'
    );

    # each lldp variable matches the following scheme:
    # $prefix.x.y.z = $value
    # whereas y is the port number

    while (my ($suffix, $mac) = each %{$lldpRemChassisId}) {
        my $port_id = _getElement($suffix, -2);
        $results->{$port_id} = {
            SYSMAC   => lc(alt2canonical($mac)),
            IFDESCR  => $lldpRemPortDesc->{$suffix},
            SYSDESCR => $lldpRemSysDesc->{$suffix},
            SYSNAME  => $lldpRemSysName->{$suffix},
            IFNUMBER => $lldpRemPortId->{$suffix}
        };
    }

    return $results;
}

sub _setTrunkPorts {
    my (%params) = @_;

    my $trunk_ports = _getTrunkPorts(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $trunk_ports;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$trunk_ports) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check vlanTrunkPortDynamicStatus mapping")
                if $logger;
            last;
        }
        $ports->{$port_id}->{TRUNK} = $trunk_ports->{$port_id};
    }
}

sub _getTrunkPorts {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $vlanStatus = $snmp->walk(
        $model->{oids}->{vlanTrunkPortDynamicStatus} ||
        '.1.3.6.1.4.1.9.9.46.1.6.1.1.14'
    );
    while (my ($suffix, $trunk) = each %{$vlanStatus}) {
        my $port_id = _getElement($suffix, -1);
        $results->{$port_id} = $trunk ? 1 : 0;
    }

    return $results;
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

=head2 loadModel($file)

Load an SNMP description model from given file.
package FusionInventory::Agent::Tools::Hardware::Generic;
