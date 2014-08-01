package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

our @EXPORT = qw(
    getDeviceInfo
    getDeviceFullInfo
);

my %types = (
    1 => 'COMPUTER',
    2 => 'NETWORKING',
    3 => 'PRINTER',
    4 => 'STORAGE',
    5 => 'POWER',
    6 => 'PHONE',
    7 => 'VIDEO',
    8 => 'KVM',
);

my %sysobjectid;

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
    'extreme'        => { vendor => 'Extreme',         type => 'NETWORKING' },
    'extremexos'     => { vendor => 'Extreme',         type => 'NETWORKING' },
    'force10'        => { vendor => 'Force10',         type => 'NETWORKING' },
    'foundry'        => { vendor => 'Foundry',         type => 'NETWORKING' },
    'fuji'           => { vendor => 'Fuji',            type => 'NETWORKING' },
    'h3c'            => { vendor => 'H3C',             type => 'NETWORKING' },
    'hp'             => { vendor => 'Hewlett-Packard',                      },
    'ibm'            => { vendor => 'IBM',             type => 'COMPUTER'   },
    'juniper'        => { vendor => 'Juniper',         type => 'NETWORKING' },
    'konica'         => { vendor => 'Konica',          type => 'PRINTER'    },
    'kyocera'        => { vendor => 'Kyocera',         type => 'PRINTER'    },
    'lexmark'        => { vendor => 'Lexmark',         type => 'PRINTER'    },
    'netapp'         => { vendor => 'NetApp',          type => 'STORAGE'    },
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
        match => qr/Switch/,
        type  => 'NETWORKING',
    },
    {
        match => qr/JETDIRECT/,
        type  => 'PRINTER',
    },
    {
        match  => qr/Linux TS-\d+/,
        type   => 'STORAGE',
        vendor => 'Qnap'
    },
);

# common base variables
my %base_variables = (
    CPU          => {
        oid  => '.1.3.6.1.4.1.9.9.109.1.1.1.1.3.1',
        type => 'count',
    },
    SNMPHOSTNAME => {
        oid  => '.1.3.6.1.2.1.1.5.0',
        type => 'string',
    },
    LOCATION     => {
        oid  => '.1.3.6.1.2.1.1.6.0',
        type => 'string',
    },
    CONTACT      => {
        oid  => '.1.3.6.1.2.1.1.4.0',
        type => 'string',
    },
    UPTIME       => {
        oid  => '.1.3.6.1.2.1.1.3.0',
        type => 'string',
    },
    MEMORY       => {
        oid  => [
            '.1.3.6.1.4.1.9.2.1.8.0',
            '.1.3.6.1.2.1.25.2.3.1.5.1',
        ],
        type => 'memory',
    },
    RAM          => {
        oid  => '.1.3.6.1.4.1.9.3.6.6.0',
        type => 'memory',
    },
);

# common interface variables
my %interface_variables = (
    IFNUMBER         => {
        oid  => '.1.3.6.1.2.1.2.2.1.1',
        type => 'none'
    },
    IFDESCR          => {
        oid  => '.1.3.6.1.2.1.2.2.1.2',
        type => 'string',
    },
    IFNAME           => {
        oid  => [
            '.1.3.6.1.2.1.31.1.1.1.1',
            '.1.3.6.1.2.1.2.2.1.2',
        ],
        type => 'string',
    },
    IFTYPE           => {
        oid  => '.1.3.6.1.2.1.2.2.1.3',
        type => 'constant',
    },
    IFMTU            => {
        oid  => '.1.3.6.1.2.1.2.2.1.4',
        type => 'count',
    },
    IFSPEED          => {
        oid  => '.1.3.6.1.2.1.2.2.1.5',
        type => 'count',
    },
    IFSTATUS         => {
        oid  => '.1.3.6.1.2.1.2.2.1.8',
        type => 'constant',
    },
    IFINTERNALSTATUS => {
        oid  => '.1.3.6.1.2.1.2.2.1.7',
        type => 'constant',
    },
    IFLASTCHANGE     => {
        oid  => '.1.3.6.1.2.1.2.2.1.9',
        type => 'none'
    },
    IFINOCTETS       => {
        oid  => '.1.3.6.1.2.1.2.2.1.10',
        type => 'count',
    },
    IFOUTOCTETS      => {
        oid  => '.1.3.6.1.2.1.2.2.1.16',
        type => 'count',
    },
    IFINERRORS       => {
        oid  => '.1.3.6.1.2.1.2.2.1.14',
        type => 'count',
    },
    IFOUTERRORS      => {
        oid  => '.1.3.6.1.2.1.2.2.1.20',
        type => 'count',
    },
    MAC              => {
        oid  => '.1.3.6.1.2.1.2.2.1.6',
        type => 'mac',
    },
    IFPORTDUPLEX     => {
        oid  => '.1.3.6.1.2.1.10.7.2.1.19',
        type => 'constant',
    },
    IFALIAS          => {
        oid  => '.1.3.6.1.2.1.31.1.1.1.18',
        type => 'string',
    },
);

my %consumables;

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
    {
        match => qr/fuser/i,
        value => 'fuser'
    },
    {
        match => qr/transfer/i,
        value => 'transfer'
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
    fuser       => 'FUSERKIT',
    transfer    => 'TRANSFERKIT',
);

# printer-specific page counter variables
my %printer_pagecounters_variables = (
    TOTAL      => {
        oid   => '.1.3.6.1.2.1.43.10.2.1.4.1.1'
    },
    BLACK      => { },
    COLOR      => { },
    RECTOVERSO => { },
    SCANNED    => { },
    PRINTTOTAL => { },
    PRINTBLACK => { },
    PRINTCOLOR => { },
    COPYTOTAL  => { },
    COPYBLACK  => { },
    COPYCOLOR  => { },
    FAXTOTAL   => { },
);

sub getDeviceInfo {
    my (%params) = @_;

    my $snmp    = $params{snmp};
    my $datadir = $params{datadir};
    my $logger  = $params{logger};

    my %device;

    # manufacturer, type and model identification attempt, using sysObjectID
    my $sysobjectid = $snmp->get('.1.3.6.1.2.1.1.2.0');
    if ($sysobjectid) {
        my ($manufacturer, $type, $model) = _getSysObjectIDInfo(
            id      => $sysobjectid,
            datadir => $datadir,
            logger  => $logger
        );
        $device{MANUFACTURER} = $manufacturer if $manufacturer;
        $device{TYPE}         = $type         if $type;
        $device{MODEL}        = $model        if $model;
    }

    # vendor and type identification attempt, using sysDescr
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
    if ($sysdescr) {

        # first word
        my ($first_word) = $sysdescr =~ /(\S+)/;
        my $result = $sysdescr_first_word{lc($first_word)};

        if ($result) {
            $device{VENDOR} = $result->{vendor} if $result->{vendor};
            $device{TYPE}   = $result->{type}   if $result->{type};
        }

        # whole sysdescr value
        foreach my $rule (@sysdescr_rules) {
            next unless $sysdescr =~ $rule->{match};
            $device{VENDOR} = $rule->{vendor} if $rule->{vendor};
            $device{TYPE}   = $rule->{type}   if $rule->{type};
            last;
        }
        $device{DESCRIPTION} = $sysdescr;
    }

    # fallback type identification attempt, using type-specific OID presence
    if (!exists $device{TYPE}) {
         if (
             $snmp->get('.1.3.6.1.2.1.43.11.1.1.6.1.1') ||
             $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1')
         ) {
            $device{TYPE} = 'PRINTER'
        }
    }

    # fallback model identification attempt, using type-specific OID value
    if (!exists $device{MODEL}) {
        my $model = exists $device{TYPE} && $device{TYPE} eq 'PRINTER' ?
            $snmp->get('.1.3.6.1.2.1.25.3.2.1.3.1')    :
            $snmp->get('.1.3.6.1.2.1.47.1.1.1.1.13.1') ;
        $device{MODEL} = $model if $model;
    }

    # fallback manufacturer identification attempt, using type-agnostic OID
    if (!exists $device{MANUFACTURER}) {
        my $manufacturer = $snmp->get('.1.3.6.1.2.1.43.8.2.1.14.1.1');
        $device{MANUFACTURER} = $manufacturer if $manufacturer;
    }

    # fallback vendor, using manufacturer
    if (!exists $device{VENDOR} && exists $device{MANUFACTURER}) {
        $device{VENDOR} = $device{MANUFACTURER};
    }

    # remaining informations
    foreach my $key (keys %base_variables) {
        my $variable = $base_variables{$key};

        my $raw_value;
        if (ref $variable->{oid} eq 'ARRAY') {
            foreach my $oid (@{$variable->{oid}}) {
                $raw_value = $snmp->get($oid);
                last if defined $raw_value;
            }
        } else {
            $raw_value = $snmp->get($variable->{oid});
        }
        next unless defined $raw_value;

        my $type = $variable->{type};
        my $value =
            $type eq 'memory' ? _getCanonicalMemory($raw_value) :
            $type eq 'string' ? _getCanonicalString($raw_value) :
            $type eq 'count'  ? _getCanonicalCount($raw_value)  :
                                $raw_value;

        $device{$key} = $value if defined $value;
    }

    my $mac = _getMacAddress($snmp);
    $device{MAC} = $mac if $mac;

    my $serial = _getSerial($snmp, $device{TYPE});
    $device{SERIAL} = $serial if $serial;

    my $firmware = _getFirmware($snmp, $device{TYPE});
    $device{FIRMWARE} = $firmware if $firmware;

    my $results = $snmp->walk('.1.3.6.1.2.1.4.20.1.1');
    $device{IPS}->{IP} =  [
        sort values %{$results}
    ] if $results;

    return %device;
}

sub _getSysObjectIDInfo {
    my (%params) = @_;

    return unless $params{id};

    _loadSysObjectIDDatabase(%params) if !%sysobjectid;

    my $logger = $params{logger};
    my $prefix = qr/(?:
        SNMPv2-SMI::enterprises |
        iso\.3\.6\.1\.4\.1      |
        \.1\.3\.6\.1\.4\.1
    )/x;
    my ($manufacturer_id, $device_id) =
        $params{id} =~ /^ $prefix \. (\d+) (?: \. (.+) )? $/x;

    # no match
    if (!$manufacturer_id) {
        $logger->debug(
            "no match in sysobjectID database: " .
            "no manufacturer ID"
        ) if $logger;
        return ();
    }

    my $manufacturer = $sysobjectid{$manufacturer_id};
    if (!$manufacturer) {
        $logger->debug(
            "no match in sysobjectID database: " .
            "unknown manufacturer ID $manufacturer_id"
        ) if $logger;
        return ();
    }

    if (!$device_id) {
        $logger->debug(
            "partial match in sysobjectID database: " .
            "no device ID"
        ) if $logger;
        return ($manufacturer->{name}, $manufacturer->{type});
    }

    my $device = $manufacturer->{devices}->{$device_id};
    if (!$device) {
        $logger->debug(
            "partial match in sysobjectID database: " .
            "unknown device ID $device_id"
        ) if $logger;
        return ($manufacturer->{name}, $manufacturer->{type});
    }

    $logger->debug("full match in sysobjectID database") if $logger;
    return ($manufacturer->{name}, $device->{type}, $device->{name});
}

sub _loadSysObjectIDDatabase {
    my (%params) = @_;

    return unless $params{datadir};

    my $handle = getFileHandle(file => "$params{datadir}/sysobject.ids");
    return unless $handle;

    my $manufacturer_id;
    while (my $line = <$handle>) {
        if ($line =~ /^\t ([\d.]+) \t ([^\t]*) (?:\t (\S+))?/x) {
            $sysobjectid{$manufacturer_id}->{devices}->{$1}->{name} = $2;
            $sysobjectid{$manufacturer_id}->{devices}->{$1}->{type} = $3;
        }

        if ($line =~ /^(\d+) \t (\S+) (?:\t (\S+))?/x) {
            $manufacturer_id = $1;
            $sysobjectid{$manufacturer_id}->{name} = $2;
            $sysobjectid{$manufacturer_id}->{type} = $3;
        }
    }

    close $handle;
}

sub _loadConsumablesDatabase {
    my (%params) = @_;

    return unless $params{datadir};

    my $handle = getFileHandle(file => "$params{datadir}/consumables.ids");
    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /(\S+) \t (\S+)/x;
        $consumables{$1} = $2;
    }

    close $handle;
}

sub _getSerial {
    my ($snmp, $type) = @_;

    my @network_oids = (
        '.1.3.6.1.2.1.47.1.1.1.1.11.1',    # Entity-MIB::entPhysicalSerialNum
        '.1.3.6.1.2.1.47.1.1.1.1.11.2',    # Entity-MIB::entPhysicalSerialNum
        '.1.3.6.1.2.1.47.1.1.1.1.11.1001', # Entity-MIB::entPhysicalSerialNum
        '.1.3.6.1.4.1.2636.3.1.3.0',       # Juniper-MIB
    );

    my @printer_oids = (
        '.1.3.6.1.2.1.43.5.1.1.17.1',      # Printer-MIB::prtGeneralSerialNumber
        '.1.3.6.1.4.1.253.8.53.3.2.1.3.1',       # Xerox-MIB
        '.1.3.6.1.4.1.367.3.2.1.2.1.4.0',        # Ricoh-MIB
        '.1.3.6.1.4.1.641.2.1.2.1.6.1',          # Lexmark-MIB
        '.1.3.6.1.4.1.1602.1.2.1.4.0',           # Canon-MIB
        '.1.3.6.1.4.1.2435.2.3.9.4.2.1.5.5.1.0', # Brother-MIB
    );

    my @oids =
        $type && $type eq 'NETWORKING' ? @network_oids :
        $type && $type eq 'PRINTER'    ? @printer_oids :
                                         (@network_oids, @printer_oids);

    foreach my $oid (@oids) {
        my $value = $snmp->get($oid);
        next unless $value;
        return _getCanonicalSerialNumber($value);
    }

    return;
}

sub _getFirmware {
    my ($snmp, $type) = @_;

    my @oids = (
        '.1.3.6.1.2.1.47.1.1.1.1.9.1',
        '.1.3.6.1.2.1.47.1.1.1.1.9.1000',
        '.1.3.6.1.2.1.47.1.1.1.1.9.1001',
        '.1.3.6.1.2.1.47.1.1.1.1.10.1',
        '.1.3.6.1.4.1.9.9.25.1.1.1.2.5'
    );

    foreach my $oid (@oids) {
        my $value = $snmp->get($oid);
        next unless $value;
        return $value;
    }

    return;
}

sub _getMacAddress {
    my ($snmp) = @_;

    # use BRIDGE-MIB::dot1dBaseBridgeAddress if available
    my $address_oid = ".1.3.6.1.2.1.17.1.1.0";
    my $address = _getCanonicalMacAddress($snmp->get($address_oid));

    return $address if $address && $address =~ /^$mac_address_pattern$/;

    # fallback on ports addresses (IF-MIB::ifPhysAddress) if unique
    my $addresses_oid = ".1.3.6.1.2.1.2.2.1.6";
    my $addresses = $snmp->walk($addresses_oid);
    my @addresses =
        uniq
        grep { $_ ne '00:00:00:00:00:00' }
        grep { $_ }
        map  { _getCanonicalMacAddress($_) }
        values %{$addresses};

    return $addresses[0] if @addresses && @addresses == 1;

    return;
}

sub getDeviceFullInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $logger = $params{logger};

    # first, let's retrieve basic device informations
    my %info = getDeviceInfo(%params);
    return unless %info;

    # description is defined as DESCRIPTION for discovery
    # and COMMENTS for inventory
    if (exists $info{DESCRIPTION}) {
        $info{COMMENTS} = $info{DESCRIPTION};
        delete $info{DESCRIPTION};
    }

    # host name is defined as SNMPHOSTNAME for discovery
    # and NAME for inventory
    if (exists $info{SNMPHOSTNAME}) {
        $info{NAME} = $info{SNMPHOSTNAME};
        delete $info{SNMPHOSTNAME};
    }

    # device ID is set from the server request
    $info{ID} = $params{id};

    # device TYPE is set either:
    # - from the server request,
    # - from initial identification
    $info{TYPE} = $params{type} || $info{TYPE};

    # second, use results to build the object
    my $device = { INFO => \%info };

    _setGenericProperties(
        device => $device,
        snmp   => $snmp,
        logger => $logger
    );

    _setPrinterProperties(
        device  => $device,
        snmp    => $snmp,
        logger  => $logger,
        datadir => $params{datadir}
    ) if $info{TYPE} && $info{TYPE} eq 'PRINTER';

    _setNetworkingProperties(
        device  => $device,
        snmp    => $snmp,
        logger  => $logger,
        datadir => $params{datadir}
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
    my $logger = $params{logger};

    # ports is a sparse hash of network ports, indexed by interface identifier
    # (ifIndex, or IFNUMBER in agent output)
    my $ports;

    foreach my $key (keys %interface_variables) {
        my $variable = $interface_variables{$key};
        next unless $variable->{oid};

        my $results;
        if (ref $variable->{oid} eq 'ARRAY') {
            foreach my $oid (@{$variable->{oid}}) {
                $results = $snmp->walk($oid);
                last if $results;
            }
        } else {
            $results = $snmp->walk($variable->{oid});
        }
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

    my $results = $snmp->walk('.1.3.6.1.2.1.4.20.1.2');
    # each result matches the following scheme:
    # $prefix.$i.$j.$k.$l = $value
    # with $i.$j.$k.$l as IP address, and $value as port id
    foreach my $suffix (sort keys %{$results}) {
        my $value = $results->{$suffix};
        next unless $value;
        # safety checks
        if (! exists $ports->{$value}) {
            $logger->error(
                "unknown interface $value for IP address $suffix, ignoring"
            ) if $logger;
            next;
        }
        if ($suffix !~ /^$ip_address_pattern$/) {
            $logger->error("invalid IP address $suffix") if $logger;
            next;
        }
        $ports->{$value}->{IP} = $suffix;
    }

    $device->{PORTS}->{PORT} = $ports;
}

sub _setPrinterProperties {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp};
    my $logger = $params{logger};

    # consumable levels
    foreach my $index (1 .. 10) {
        my $description_oid = '.1.3.6.1.2.1.43.11.1.1.6.1.' . $index;
        my $description = hex2char($snmp->get($description_oid));
        last unless $description;

        my $max_oid     = '.1.3.6.1.2.1.43.11.1.1.8.1.' . $index;
        my $current_oid = '.1.3.6.1.2.1.43.11.1.1.9.1.' . $index;
        my $max     = $snmp->get($max_oid);
        my $current = $snmp->get($current_oid);
        next unless defined $max and defined $current;

        # consumable identification
        my $variable =
            _getConsumableVariableFromDescription(
                datadir     => $params{datadir},
                description => $description
            );
        next unless $variable;

        my $value;
        if ($current == -3) {
            # OK means 100% for a container, but 0% for a receptacle
            $value = $variable eq 'WASTETONER' ? 0 : 100;
        } else {
            $value = _getPercentValue($max, $current);
        }
        next unless defined $value;

        $device->{CARTRIDGES}->{$variable} = $value;
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_variables) {
        my $variable = $printer_pagecounters_variables{$key};
        my $oid = $variable->{oid};
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
    my (%params) = @_;

    my $description = $params{description};
    return unless $description;

    _loadConsumablesDatabase(%params) if !%consumables;

    foreach my $key (keys %consumables) {
        return $consumables{$key} if $description =~ /$key/;
    }

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
    my $logger = $params{logger};

    my $ports    = $device->{PORTS}->{PORT};

    _setVlans(
        snmp   => $snmp,
        ports  => $ports,
        logger => $logger
    );

    _setTrunkPorts(
        snmp   => $snmp,
        ports  => $ports,
        logger => $logger
    );

    _setConnectedDevices(
        snmp   => $snmp,
        ports  => $ports,
        logger => $logger,
        vendor => $device->{INFO}->{MANUFACTURER}
    );

    _setKnownMacAddresses(
        snmp         => $snmp,
        ports        => $ports,
        logger       => $logger,
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

    return if $result eq '00:00:00:00:00:00';
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

sub _setKnownMacAddresses {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $ports  = $params{ports};
    my $logger = $params{logger};

    # start with mac addresses seen on default VLAN
    my $addresses = _getKnownMacAddresses(
        snmp           => $snmp,
        address2port   => '.1.3.6.1.2.1.17.4.3.1.2', # dot1dTpFdbPort
        port2interface => '.1.3.6.1.2.1.17.1.4.1.2', # dot1dBasePortIfIndex
    );

    if ($addresses) {
        _addKnownMacAddresses(
            ports     => $ports,
            logger    => $logger,
            addresses => $addresses,
        );
    }

    # add additional mac addresses for other VLANs
    $addresses = _getKnownMacAddresses(
        snmp           => $snmp,
        address2port   => '.1.3.6.1.2.1.17.7.1.2.2.1.2', # dot1qTpFdbPort
        port2interface => '.1.3.6.1.2.1.17.1.4.1.2',     # dot1dBasePortIfIndex
    );

    if ($addresses) {
        _addKnownMacAddresses(
            ports     => $ports,
            logger    => $logger,
            addresses => $addresses,
        );
    } else {
        # compute the list of vlans associated with at least one port
        # without CDP/LLDP information
        my @vlans;
        my %seen = ( 1 => 1 );
        foreach my $port (values %$ports) {
            next if
                exists $port->{CONNECTIONS} &&
                exists $port->{CONNECTIONS}->{CDP} &&
                $port->{CONNECTIONS}->{CDP};
            next unless exists $port->{VLANS};
            push @vlans,
                grep { !$seen{$_}++ }
                map { $_->{NUMBER} }
                @{$port->{VLANS}->{VLAN}};
        }

        # get additional associated mac addresses from those vlans
        foreach my $vlan (@vlans) {
            $logger->debug("switching SNMP context to vlan $vlan") if $logger;
            $snmp->switch_vlan_context($vlan);
            my $mac_addresses = _getKnownMacAddresses(
                snmp           => $snmp,
                address2port   => '.1.3.6.1.2.1.17.4.3.1.2', # dot1dTpFdbPort
                port2interface => '.1.3.6.1.2.1.17.1.4.1.2', # dot1dBasePortIfIndex
            );
            next unless $mac_addresses;

            _addKnownMacAddresses(
                ports     => $ports,
                logger    => $logger,
                addresses => $mac_addresses,
            );
        }
        $snmp->reset_original_context() if @vlans;
    }

}

sub _addKnownMacAddresses {
    my (%params) = @_;

    my $ports         = $params{ports};
    my $logger        = $params{logger};
    my $mac_addresses = $params{addresses};

    foreach my $port_id (keys %$mac_addresses) {
        # safety check
        if (! exists $ports->{$port_id}) {
            $logger->error(
                "invalid interface ID $port_id while setting known mac " .
                "addresses, aborting"
            ) if $logger;
            next;
        }

        my $port = $ports->{$port_id};

        # connected device has already been identified through CDP/LLDP
        next if
            exists $port->{CONNECTIONS} &&
            exists $port->{CONNECTIONS}->{CDP} &&
            $port->{CONNECTIONS}->{CDP};

        # get at list of already associated addresses, if any
        # as well as the port own mac address, if known
        my @known;
        push @known, $port->{MAC} if $port->{MAC};
        push @known, @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}} if
            exists $port->{CONNECTIONS} &&
            exists $port->{CONNECTIONS}->{CONNECTION} &&
            exists $port->{CONNECTIONS}->{CONNECTION}->{MAC};

        # filter out those addresses from the additional ones
        my %known = map { $_ => 1 } @known;
        my @adresses = grep { !$known{$_} } @{$mac_addresses->{$port_id}};
        next unless @adresses;

        # add remaining ones
        push @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}}, @adresses;
    }
}

sub _getKnownMacAddresses {
    my (%params) = @_;

    my $snmp   = $params{snmp};

    my $results;
    my $address2port   = $snmp->walk($params{address2port});
    my $port2interface = $snmp->walk($params{port2interface});

    # dot1dTpFdbPort values matches the following scheme:
    # $prefix.a.b.c.d.e.f = $port

    # dot1qTpFdbPort values matches the following scheme:
    # $prefix.$vlan.a.b.c.d.e.f = $port

    # in both case, the last 6 elements of the OID constitutes
    # the mac address in decimal format
    foreach my $suffix (sort keys %{$address2port}) {
        my $port_id      = $address2port->{$suffix};
        my $interface_id = $port2interface->{$port_id};
        next unless defined $interface_id;

        my @bytes = split(/\./, $suffix);
        shift @bytes if @bytes > 6;

        push @{$results->{$interface_id}},
            sprintf "%02x:%02x:%02x:%02x:%02x:%02x", @bytes;
    }

    return $results;
}

sub _setConnectedDevices {
    my (%params) = @_;

    my $logger = $params{logger};
    my $ports  = $params{ports};

    my $lldp_info = _getLLDPInfo(%params);
    if ($lldp_info) {
        foreach my $interface_id (keys %$lldp_info) {
            # safety check
            if (! exists $ports->{$interface_id}) {
                $logger->error(
                    "unknown interface $interface_id in LLDP info, ignoring"
                ) if $logger;
                next;
            }

            my $port            = $ports->{$interface_id};
            my $lldp_connection = $lldp_info->{$interface_id};

            $port->{CONNECTIONS} = {
                CDP        => 1,
                CONNECTION => $lldp_connection
            };
        }
    }

    my $cdp_info = _getCDPInfo(%params);
    if ($cdp_info) {
        foreach my $interface_id (keys %$cdp_info) {
            # safety check
            if (! exists $ports->{$interface_id}) {
                $logger->error(
                    "unknown interface $interface_id in CDP info, ignoring"
                ) if $logger;
                next;
            }

            my $port            = $ports->{$interface_id};
            my $lldp_connection = $port->{CONNECTIONS}->{CONNECTION};
            my $cdp_connection  = $cdp_info->{$interface_id};

            if ($lldp_connection) {
                if ($cdp_connection->{SYSDESCR} eq $lldp_connection->{SYSDESCR}) {
                    # same device, everything OK
                    foreach my $key (qw/IP MODEL/) {
                        $lldp_connection->{$key} = $cdp_connection->{$key};
                    }
                } else {
                    # undecidable situation
                    $logger->error(
                        "multiple neighbors found by LLDP and CDP for " .
                        "interface $interface_id, ignoring"
                    );
                    delete $port->{CONNECTIONS};
                }
            } else {
                $port->{CONNECTIONS} = {
                    CDP        => 1,
                    CONNECTION => $cdp_connection
                };
            }
        }
    }

    my $edp_info = _getEDPInfo(%params);
    if ($edp_info) {
        foreach my $interface_id (keys %$edp_info) {
            # safety check
            if (! exists $ports->{$interface_id}) {
                $logger->error(
                    "unknown interface $interface_id in EDP info, ignoring"
                ) if $logger;
                next;
            }

            my $port            = $ports->{$interface_id};
            my $lldp_connection = $port->{CONNECTIONS}->{CONNECTION};
            my $edp_connection  = $edp_info->{$interface_id};

            if ($lldp_connection) {
                if ($edp_connection->{SYSDESCR} eq $lldp_connection->{SYSDESCR}) {
                    # same device, everything OK
                    foreach my $key (qw/IP/) {
                        $lldp_connection->{$key} = $edp_connection->{$key};
                    }
                } else {
                    # undecidable situation
                    $logger->error(
                        "multiple neighbors found by LLDP and EDP for " .
                        "interface $interface_id, ignoring"
                    );
                    delete $port->{CONNECTIONS};
                }
            } else {
                $port->{CONNECTIONS} = {
                    CDP        => 1,
                    CONNECTION => $edp_connection
                };
            }
        }
    }
}

sub _getLLDPInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};

    my $results;
    my $lldpRemChassisId = $snmp->walk('.1.0.8802.1.1.2.1.4.1.1.5');
    my $lldpRemPortId    = $snmp->walk('.1.0.8802.1.1.2.1.4.1.1.7');
    my $lldpRemPortDesc  = $snmp->walk('.1.0.8802.1.1.2.1.4.1.1.8');
    my $lldpRemSysName   = $snmp->walk('.1.0.8802.1.1.2.1.4.1.1.9');
    my $lldpRemSysDesc   = $snmp->walk('.1.0.8802.1.1.2.1.4.1.1.10');

    # port to interface mapping
    my $port2interface =
        $snmp->walk('.1.3.6.1.4.1.9.5.1.4.1.1.11.1') || # Cisco portIfIndex
        $snmp->walk('.1.3.6.1.2.1.17.1.4.1.2');         # dot1dBasePortIfIndex

    # each lldp variable matches the following scheme:
    # $prefix.x.y.z = $value
    # whereas y is either a port or an interface id

    while (my ($suffix, $mac) = each %{$lldpRemChassisId}) {
        my $id           = _getElement($suffix, -2);
        my $interface_id =
            ! exists $port2interface->{$id} ? $id                   :
            $params{vendor} eq 'Juniper'    ? $id                   :
                                              $port2interface->{$id};


        my $connection = {
            SYSMAC   => lc(alt2canonical($mac)),
            IFDESCR  => $lldpRemPortDesc->{$suffix},
            SYSDESCR => $lldpRemSysDesc->{$suffix},
            SYSNAME  => hex2char($lldpRemSysName->{$suffix}),
            IFNUMBER => $lldpRemPortId->{$suffix}
        };

        next if !$connection->{SYSDESCR};

        $results->{$interface_id} = $connection;
    }

    return $results;
}

sub _getCDPInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $logger = $params{logger};

    my ($results, $blacklist);
    my $cdpCacheAddress    = $snmp->walk('.1.3.6.1.4.1.9.9.23.1.2.1.1.4');
    my $cdpCacheVersion    = $snmp->walk('.1.3.6.1.4.1.9.9.23.1.2.1.1.5');
    my $cdpCacheDeviceId   = $snmp->walk('.1.3.6.1.4.1.9.9.23.1.2.1.1.6');
    my $cdpCacheDevicePort = $snmp->walk('.1.3.6.1.4.1.9.9.23.1.2.1.1.7');
    my $cdpCachePlatform   = $snmp->walk('.1.3.6.1.4.1.9.9.23.1.2.1.1.8');

    # each cdp variable matches the following scheme:
    # $prefix.x.y = $value
    # whereas x is the port number

    while (my ($suffix, $ip) = each %{$cdpCacheAddress}) {
        my $interface_id = _getElement($suffix, -2);
        $ip = hex2canonical($ip);
        next if $ip eq '0.0.0.0';

        my $connection = {
            IP       => $ip,
            SYSDESCR => $cdpCacheVersion->{$suffix},
            MODEL    => $cdpCachePlatform->{$suffix}
        };

        # cdpCacheDevicePort is either a port number or a port description
        my $devicePort = $cdpCacheDevicePort->{$suffix};
        if ($devicePort =~ /^\d+$/) {
            $connection->{IFNUMBER} = $devicePort;
        } else {
            $connection->{IFDESCR} = $devicePort;
        }

        # cdpCacheDeviceId is either remote host name, either remote mac address
        my $deviceId = $cdpCacheDeviceId->{$suffix};
        if ($deviceId =~ /^0x/) {
            if (length($deviceId) == 14) {
                # let's assume it is a mac address if the length is 6 bytes
                $connection->{SYSMAC} = lc(alt2canonical($deviceId));
            } else {
                # otherwise it's an hex-encode hostname
                $connection->{SYSNAME} = hex2char($deviceId);
            }
        } else {
            $connection->{SYSNAME} = $deviceId;
        }

        if ($connection->{SYSNAME} &&
            $connection->{SYSNAME} =~ /^SIP([A-F0-9a-f]*)$/) {
            $connection->{MAC} = lc(alt2canonical("0x".$1));
        }

        next if !$connection->{SYSDESCR} || !$connection->{MODEL};

        # warning: multiple neighbors announcement for the same interface
        # usually means a non-CDP aware intermediate equipement
        if ($results->{$interface_id}) {
            $logger->error(
                "multiple neighbors found by CDP for interface $interface_id," .
                " ignoring"
            );
            $blacklist->{$interface_id} = 1;
        } else {
            $results->{$interface_id} = $connection;
        }
    }

    # remove blacklisted results
    delete $results->{$_} foreach keys %$blacklist;

    return $results;
}

sub _getEDPInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $logger = $params{logger};

    my ($results, $blacklist);
    my $edpNeighborVlanIpAddress = $snmp->walk('.1.3.6.1.4.1.1916.1.13.3.1.3');
    my $edpNeighborName          = $snmp->walk('.1.3.6.1.4.1.1916.1.13.2.1.3');
    my $edpNeighborPort          = $snmp->walk('.1.3.6.1.4.1.1916.1.13.2.1.6');

    # each entry from extremeEdpTable matches the following scheme:
    # $prefix.x.0.0.y1.y2.y3.y4.y5.y6 = $value
    # - x: the interface id
    # - y1.y2.y3.y4.y5.y6: the remote mac address

    # each entry from extremeEdpNeighborTable matches the following scheme:
    # $prefix.x.0.0.y1.y2.y3.y4.y5.y6.z1.z2...zz = $value
    # - x: the interface id,
    # - y1.y2.y3.y4.y5.y6: the remote mac address
    # - z1.z2...zz: the vlan name in ASCII

    while (my ($suffix, $ip) = each %{$edpNeighborVlanIpAddress}) {
        next if $ip eq '0.0.0.0';

        my $interface_id = _getElement($suffix, 0);
        my @mac_elements = _getElements($suffix, 3, 8);
        my $short_suffix = join('.', $interface_id, 0, 0, @mac_elements);

        my $connection = {
            IP       => $ip,
            IFDESCR  => $edpNeighborPort->{$short_suffix},
            SYSNAME  => $edpNeighborName->{$short_suffix},
            SYSMAC   => sprintf "%02x:%02x:%02x:%02x:%02x:%02x", @mac_elements
        };

        # warning: multiple neighbors announcement for the same interface
        # usually means a non-EDP aware intermediate equipement
        if ($results->{$interface_id}) {
            $logger->error(
                "multiple neighbors found by EDP for interface $interface_id," .
                " ignoring"
            );
            $blacklist->{$interface_id} = 1;
        } else {
            $results->{$interface_id} = $connection;
        }
    }

    # remove blacklisted results
    delete $results->{$_} foreach keys %$blacklist;

    return $results;
}


sub _setVlans {
    my (%params) = @_;

    my $vlans = _getVlans(
        snmp  => $params{snmp},
    );
    return unless $vlans;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$vlans) {
        # safety check
        if (! exists $ports->{$port_id}) {
            $logger->error(
                "invalid interface ID $port_id while setting vlans, aborting"
            ) if $logger;
            last;
        }
        $ports->{$port_id}->{VLANS}->{VLAN} = $vlans->{$port_id};
    }
}

sub _getVlans {
    my (%params) = @_;

    my $snmp = $params{snmp};

    my $results;
    my $vtpVlanName  = $snmp->walk('.1.3.6.1.4.1.9.9.46.1.3.1.1.4.1');
    my $vmPortStatus = $snmp->walk('.1.3.6.1.4.1.9.9.68.1.2.2.1.2');

    # each result matches either of the following schemes:
    # $prefix.$i.$j = $value, with $j as port id, and $value as vlan id
    # $prefix.$i    = $value, with $i as port id, and $value as vlan id
    foreach my $suffix (sort keys %{$vmPortStatus}) {
        my $port_id = _getElement($suffix, -1);
        my $vlan_id = $vmPortStatus->{$suffix};
        my $name    = $vtpVlanName->{$vlan_id};

        push @{$results->{$port_id}}, {
            NUMBER => $vlan_id,
            NAME   => $name
        };
    }

    return $results;
}

sub _setTrunkPorts {
    my (%params) = @_;

    my $trunk_ports = _getTrunkPorts(
        snmp  => $params{snmp},
    );
    return unless $trunk_ports;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$trunk_ports) {
        # safety check
        if (! exists $ports->{$port_id}) {
            $logger->error(
                "invalid interface ID $port_id while setting trunk flag, " .
                "aborting"
            ) if $logger;
            last;
        }
        $ports->{$port_id}->{TRUNK} = $trunk_ports->{$port_id};
    }
}

sub _getTrunkPorts {
    my (%params) = @_;

    my $snmp   = $params{snmp};

    my $results;

    # cisco use vlanTrunkPortDynamicStatus, using the following schema:
    # prefix.x = value
    # x is the interface id
    # value is 1 for trunk, 2 for access
    my $vlanStatus = $snmp->walk('.1.3.6.1.4.1.9.9.46.1.6.1.1.14');
    if ($vlanStatus) {
        while (my ($interface_id, $value) = each %{$vlanStatus}) {
            $results->{$interface_id} = $value == 1 ? 1 : 0;
        }
        return $results;
    }

    # juniper use jnxExVlanPortAccessMode, using the following schema:
    # prefix.x.y = value
    # x is the vlan id
    # y is the port id
    # value is 1 for access, 2 for trunk
    my $accessMode = $snmp->walk('.1.3.6.1.4.1.2636.3.40.1.5.1.7.1.5');
    if ($accessMode) {
        my $port2interface = $snmp->walk('.1.3.6.1.2.1.17.1.4.1.2');
        while (my ($suffix, $value) = each %{$accessMode}) {
            my $port_id = _getElement($suffix, -1);
            my $interface_id = $port2interface->{$port_id};
            $results->{$interface_id} = $value == 2 ? 1 : 0;
        }
        return $results;
    }


    # others use lldpXdot1LocPortVlanId
    # prefix.x = value
    # x is either an interface or a port id
    # value is the vlan id, 0 for trunk
    my $vlanId = $snmp->walk('.1.0.8802.1.1.2.1.5.32962.1.2.1.1.1');
    if ($vlanId) {
        my $port2interface = $snmp->walk('.1.3.6.1.2.1.17.1.4.1.2');
        while (my ($id, $value) = each %{$vlanId}) {
            my $interface_id =
                ! exists $port2interface->{$id} ? $id                   :
                                                  $port2interface->{$id};
            $results->{$interface_id} = $value == 0 ? 1 : 0;
        }
        return $results;
    }

    return;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Hardware - Hardware-related functions

=head1 DESCRIPTION

This module provides some hardware-related functions.

=head1 FUNCTIONS

=head2 getDeviceInfo(%params)

return a limited set of information for a device through SNMP.

=head2 getDeviceFullInfo(%params)

return a full set of information for a device through SNMP.
