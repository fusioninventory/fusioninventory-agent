package FusionInventory::Agent::Tools::Hardware;

use strict;
use warnings;
use base 'Exporter';

use FusionInventory::Agent::Tools; # runFunction
use FusionInventory::Agent::Tools::Network;

our @EXPORT = qw(
    getDeviceBaseInfo
    getDeviceInfo
    setTrunkPorts
    setConnectedDevices
    setConnectedDevicesMacAddresses
    performSpecificCleanup
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

sub setTrunkPorts {
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
sub setConnectedDevices {
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

sub setConnectedDevicesMacAddresses {
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

sub performSpecificCleanup {
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
