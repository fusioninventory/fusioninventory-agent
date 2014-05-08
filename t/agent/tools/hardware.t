#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;

my @mac_tests = (
    [ 'd2:05:a8:6c:26:d5' , 'd2:05:a8:6c:26:d5' ],
    [ '0xD205A86C26D5'    , 'd2:05:a8:6c:26:d5' ],
    [ '0x6001D205A86C26D5', 'd2:05:a8:6c:26:d5' ],
);

my @consumable_tests = (
    [ "Bias Transfer Roll", undef ],
    [ "Black Cartridge ", undef ],
    [ "Black Cartridge", undef ],
    [ "Black Cartridge HP CB540A", undef ],
    [ "Black Cartridge HP CC530A", undef ],
    [ "Black Cartridge HP CE310A", undef ],
    [ "Black Cartridge HP CE320A", undef ],
    [ "Black Cartridge HP CE410A", undef ],
    [ "Black Cartridge HP Q5942X", undef ],
    [ "Black Cartridge HP Q6470A", undef ],
    [ "Black Cartridge HP Q7551A", undef ],
    [ "Black Cartridge HP Q7551X", undef ],
    [ "Black, ColorQube 8570", undef ],
    [ "Black Drum Cartridge", 'DRUMBLACK' ],
    [ "black ink", 'CARTRIDGEBLACK' ],
    [ "Black Ink, Phaser 8500/8550, PN 108R00668", 'CARTRIDGEBLACK' ],
    [ "Black Photoconductive Drum", 'DRUMBLACK' ],
    [ "Black Print Cartridge HP C9730A", undef ],
    [ "Black Print Cartridge HP Q1338A", undef ],
    [ "Black Print Cartridge HP Q2610A", undef ],
    [ "Black Toner", 'TONERBLACK' ],
    [ "Black Toner Cartridge HP Q6000A", 'TONERBLACK' ],
    [ "Black Toner [K] Cartridge", 'TONERBLACK' ],
    [ "Black Toner [K] Cartridge;SN190E8280E0000466", 'TONERBLACK' ],
    [ "Bouteille rcup.", undef ],
    [ "Canon Cartridge 718 Black", undef ],
    [ "Canon Cartridge 718 Cyan", undef ],
    [ "Canon Cartridge 718 Magenta", undef ],
    [ "Canon Cartridge 718 Yellow", undef ],
    [ "Canon Cartridge 728", undef ],
    [ "Cartouche cyan, ", undef ],
    [ "Cartouche de cya", undef ],
    [ "Cartouche de jau", undef ],
    [ "Cartouche de mag", undef ],
    [ "Cartouche d'encre" =>  undef ],
    [ "CARTOUCHE D'ENCRE HP C4127X" =>  undef ],
    [ "Cartouche de noi", undef ],
    [ "Cartouche jaune,", undef ],
    [ "Cartouche magent", undef ],
    [ "Cartouche Noir HP CE505A", undef ],
    [ "Cartouche Noir HP CE505X", undef ],
    [ "CE285A", undef ],
    [ "CE310A", undef ],
    [ "CE311A", undef ],
    [ "CE312A", undef ],
    [ "CE313A", undef ],
    [ "CE314A", undef ],
    [ "C-KIT DC2118", undef ],
    [ "Courroie transfert", undef ],
    [ "Cyan Cartridge H", undef ],
    [ "Cyan Cartridge HP CB541A", undef ],
    [ "Cyan Cartridge HP CC531A", undef ],
    [ "Cyan Cartridge HP CE311A", undef ],
    [ "Cyan Cartridge HP CE321A", undef ],
    [ "Cyan Cartridge HP CE411A", undef ],
    [ "Cyan Cartridge HP Q6471A", undef ],
    [ "Cyan, ColorQube 8570", undef ],
    [ "Cyan Developer", undef ],
    [ "Cyan Drum Cartridge", 'DRUMCYAN' ],
    [ "cyan ink", 'CARTRIDGECYAN' ],
    [ "Cyan Ink, Phaser 8500/8550, PN 108R00669", 'CARTRIDGECYAN' ],
    [ "Cyan Photoconductive Drum", 'DRUMCYAN' ],
    [ "Cyan Print Cartridge HP C9731A", undef ],
    [ "Cyan Toner", 'TONERCYAN' ],
    [ "Cyan Toner Cartridge HP Q6001A", 'TONERCYAN' ],
    [ "Cyan Toner [C] Cartridge", 'TONERCYAN' ],
    [ "Cyan Toner [C] Cartridge;SN0F1FCB80E0000461", 'TONERCYAN' ],
    [ "Dell", undef ],
    [ "Developer Cartridge (Cyan)", undef ],
    [ "Developer Cartridge (Magenta)", undef ],
    [ "Developer Cartridge (Yellow)", undef ],
    [ "Diamond Fine Toner", undef ],
    [ "Drum Cartridge (Cyan)", 'DRUMCYAN' ],
    [ "Drum Cartridge (Magenta)", 'DRUMMAGENTA' ],
    [ "Drum Cartridge, Phaser 5550-PagePack, P/N 113R00685", undef ],
    [ "Drum Cartridge (Yellow)", 'DRUMYELLOW' ],
    [ "Extended-Capacity Maintenance Kit, Phaser 8550/8560/8560MFP, P/N 108R00676", 'MAINTENANCEKIT' ],
    [ "Fuser CRU module", undef ],
    [ "Fuser, Phaser 61", undef ],
    [ "Fuser Unit", undef ],
    [ "Genuine Xerox Solid Ink Black, Phaser 8560/8560MFP, P/N 108R00727", 'CARTRIDGEBLACK' ],
    [ "Genuine Xerox Solid Ink Cyan, Phaser 8560/8560MFP, P/N 108R00723", 'CARTRIDGECYAN' ],
    [ "Genuine Xerox Solid Ink Magenta, Phaser 8560/8560MFP, P/N 108R00724", 'CARTRIDGEMAGENTA' ],
    [ "Genuine Xerox Solid Ink Yellow, Phaser 8560/8560MFP, P/N 108R00725", 'CARTRIDGEYELLOW' ],
    [ "Image Fuser Kit ", undef ],
    [ "Image Fuser Kit HP 110V-Q3984A, 220V-Q3985A", undef ],
    [ "Image Transfer K", undef ],
    [ "Image Transfer Kit HP C9734B", undef ],
    [ "Imaging Drum HP CE314A", undef ],
    [ "Kit de fusion HP", undef ],
    [ "Kit de maintenan", undef ],
    [ "Magenta Cartridg", undef ],
    [ "Magenta Cartridge HP CB543A", undef ],
    [ "Magenta Cartridge HP CC533A", undef ],
    [ "Magenta Cartridge HP CE313A", undef ],
    [ "Magenta Cartridge HP CE323A", undef ],
    [ "Magenta Cartridge HP CE413A", undef ],
    [ "Magenta Cartridge HP Q6473A", undef ],
    [ "Magenta, ColorQube 8570", undef ],
    [ "Magenta Drum Cartridge", 'DRUMMAGENTA' ],
    [ "magenta ink", 'CARTRIDGEMAGENTA' ],
    [ "Magenta Ink, Phaser 8500/8550, PN 108R00670", 'CARTRIDGEMAGENTA' ],
    [ "Magenta Photoconductive Drum", 'DRUMMAGENTA' ],
    [ "Magenta Print Cartridge HP C9733A", undef ],
    [ "Magenta Toner", 'TONERMAGENTA' ],
    [ "Magenta Toner Cartridge HP Q6003A", 'TONERMAGENTA' ],
    [ "Magenta Toner [M] Cartridge", 'TONERMAGENTA' ],
    [ "Magenta Toner [M] Cartridge;SN1031F080E0000468", 'TONERMAGENTA' ],
    [ "Maintenance Kit ", 'MAINTENANCEKIT'],
    [ "Maintenance Kit", 'MAINTENANCEKIT' ],
    [ "Maintenance Kit HP 110V-Q2429A, 220V-Q2430A", 'MAINTENANCEKIT' ],
    [ "Maintenance Kit HP 110V-Q5421A, 220V-Q5422A", 'MAINTENANCEKIT' ],
    [ "Maintenance Kit, Phaser 5550, P/N 115R00033(110V) / P/N 115R00034(220 V)", 'MAINTENANCEKIT' ],
    [ "Maintenance Kit, Phaser 8550, PN 108R00676", 'MAINTENANCEKIT' ],
    [ "Print Cartridge", undef ],
    [ "Roul. sparateur", undef ],
    [ "Standard-Capacity Maintenance Kit, ColorQube 8570, P/N 109R00784", 'MAINTENANCEKIT' ],
    [ "Standard-Capacity Maintenance Kit, Phaser 8500/8550/8560/8560MFP, P/N 108R00675", 'MAINTENANCEKIT' ],
    [ "Staple Unit", undef ],
    [ "TK-560C", undef ],
    [ "TK-560K", undef ],
    [ "TK-560M", undef ],
    [ "TK-560Y", undef ],
    [ "toner", undef ],
    [ "Toner (Black)", 'TONERBLACK' ],
    [ "Toner Bottle CRU", undef ],
    [ "Toner Cartridge", undef ],
    [ "Toner Cartridge HP C4127X", undef ],
    [ "Toner Cartridge, Phaser 5550-PagePack, P/N 113R00684", undef ],
    [ "Toner Collection", undef ],
    [ "Toner Container", undef ],
    [ "Toner cyan", 'TONERCYAN' ],
    [ "Toner (Cyan)", 'TONERCYAN' ],
    [ "Toner jaune", 'TONERYELLOW' ],
    [ "Toner magenta", 'TONERMAGENTA' ],
    [ "Toner (Magenta)", 'TONERMAGENTA' ],
    [ "Toner noir", 'TONERBLACK' ],
    [ "Toner usagé", undef ],
    [ "Toner usagé 1", undef ],
    [ "Toner usagé 2", undef ],
    [ "Toner (Yellow)", 'TONERYELLOW' ],
    [ "Unit de fusion", undef ],
    [ "Unit? de r?cup. ", undef ],
    [ "UnitÃ© de transf", undef ],
    [ "Waste Toner", 'WASTETONER' ],
    [ "Waste Toner Bottle CRU", 'WASTETONER' ],
    [ "Waste Toner Box", 'WASTETONER' ],
    [ "Waste Toner Container", 'WASTETONER' ],
    [ "Waste Tray, ColorQube 8570, P/N 109R00754", 'WASTETONER' ],
    [ "Waste Tray, Phaser 8500/8550, PN 108R00754", 'WASTETONER' ],
    [ "Waste Tray, Phaser 8500 Series, P/N 109R00754", 'WASTETONER' ],
    [ "Xerographic CRU module", undef ],
    [ "Xerox Black Print Cartridge, Replace with PN 106R02651;SN 13021712973", undef ],
    [ "Yellow Cartridge", undef ],
    [ "Yellow Cartridge HP CB542A", undef ],
    [ "Yellow Cartridge HP CC532A", undef ],
    [ "Yellow Cartridge HP CE312A", undef ],
    [ "Yellow Cartridge HP CE322A", undef ],
    [ "Yellow Cartridge HP CE412A", undef ],
    [ "Yellow Cartridge HP Q6472A", undef ],
    [ "Yellow, ColorQube 8570", undef ],
    [ "Yellow Drum Cartridge", 'DRUMYELLOW' ],
    [ "yellow ink", 'CARTRIDGEYELLOW' ],
    [ "Yellow Ink, Phaser 8500/8550, PN 108R00671", 'CARTRIDGEYELLOW' ],
    [ "Yellow Photoconductive Drum", 'DRUMYELLOW' ],
    [ "Yellow Print Cartridge HP C9732A", undef ],
    [ "Yellow Toner", 'TONERYELLOW' ],
    [ "Yellow Toner Cartridge HP Q6002A", 'TONERYELLOW' ],
    [ "Yellow Toner [Y] Cartridge", 'TONERYELLOW' ],
    [ "Yellow Toner [Y] Cartridge;SN0A1F3080E0000468", 'TONERYELLOW' ],
    [ "Zone de perfor.", undef ],
);

# each item is an arrayref of 3 elements:
# - raw SNMP values
# - expected output
# - test description
my @cdp_info_extraction_tests = (
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        {
            24 => {
                MAC      => 'e0:5f:b9:81:a7:a7',
                SYSDESCR => '7.4.9c',
                IFDESCR  => 'Port 1',
                MODEL    => 'Cisco IP Phone SPA508G',
                IP       => '192.168.20.139',
                SYSNAME  => 'SIPE05FB981A7A7'
             }
        },
        'CDP info extraction'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        undef,
        'CDP info extraction, missing CDP cache version'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
        },
        undef,
        'CDP info extraction, missing CDP cache platform'
    ],
);

# each item is an arrayref of 3 elements:
# - raw SNMP values
# - expected output
# - test explication
my @mac_addresses_extraction_tests = (
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => [ '00:00:74:d2:09:6a' ]
        },
        'mac addresses extraction, single address'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.107' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => [ '00:00:74:d2:09:6a', '00:00:74:d2:09:6b' ]
        },
        'mac addresses extraction, two addresses'
    ],
);

# each item is an arrayref of 4 elements:
# - raw SNMP values
# - initial port list
# - expected final port list
# - test explication
my @mac_addresses_addition_tests = (
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => {
            }
        },
        {
            52 => {
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ '00:00:74:d2:09:6a' ]
                    }
                },
            }
        },
        'mac addresses addition, single address'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.107' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => {
            }
        },
        {
            52 => {
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ '00:00:74:d2:09:6a', '00:00:74:d2:09:6b' ]
                    }
                },
            }
        },
        'mac addresses addition, two addresses'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.107' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => {
                CONNECTIONS => {
                    CDP => 1,
                },
            }
        },
        {
            52 => {
                CONNECTIONS => {
                    CDP => 1,
                },
            }
        },
        'mac addresses addition, CDP/LLDP info already present'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.107' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
        {
            52 => {
                MAC => '00:00:74:d2:09:6a',
            }
        },
        {
            52 => {
                MAC         => '00:00:74:d2:09:6a',
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ '00:00:74:d2:09:6b' ]
                    }
                },
            }
        },
        'mac addresses addition, exclusion of port own address'
    ],
);

# each item is an arrayref of 3 elements:
# - raw SNMP values
# - expected output
# - test description
my @trunk_ports_extraction_tests = (
    [
        {
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.0' => [ 'INTEGER', 1  ],
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1' => [ 'INTEGER', 0  ],
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.2' => [ 'INTEGER', 1  ]
        },
        {
            0 => 1,
            1 => 0,
            2 => 1,
        },
        'trunk ports extraction'
    ]
);

plan tests =>
    scalar @mac_tests                      +
    scalar @consumable_tests               +
    scalar @cdp_info_extraction_tests      +
    scalar @mac_addresses_extraction_tests +
    scalar @mac_addresses_addition_tests   +
    scalar @trunk_ports_extraction_tests   +
    7;

foreach my $test (@mac_tests) {
    is(
        FusionInventory::Agent::Tools::Hardware::_getCanonicalMacAddress($test->[0]),
        $test->[1],
        "$test->[0] normalisation"
    );
}

foreach my $test (@consumable_tests) {
    is(
        FusionInventory::Agent::Tools::Hardware::_getConsumableVariableFromDescription($test->[0]),
        $test->[1],
        "$test->[0] identification"
    );
}

my $snmp1 = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
    }
);

my %device1 = getDeviceInfo(snmp => $snmp1);
cmp_deeply(
    \%device1,
    { DESCRIPTION => 'foo' },
    'getDeviceInfo() with no sysobjectid'
);

my $snmp2 = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
        '.1.3.6.1.2.1.1.2.0'        => [ 'STRING', '.1.3.6.1.4.1.45' ],
    }
);

my %device2 = getDeviceInfo(snmp => $snmp2);
cmp_deeply(
    \%device2,
    {
        DESCRIPTION  => 'foo',
        TYPE         => 'NETWORKING',
        MANUFACTURER => 'Nortel',
        VENDOR       => 'Nortel'
    },
    'getDeviceInfo() with sysobjectid'
);

foreach my $test (@cdp_info_extraction_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    my $cdp_info = FusionInventory::Agent::Tools::Hardware::_getConnectedDevicesInfoCDP(
        snmp  => $snmp,
    );

    cmp_deeply(
        $cdp_info,
        $test->[1],
        $test->[2]
    );
}

foreach my $test (@mac_addresses_extraction_tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    my $mac_addresses = FusionInventory::Agent::Tools::Hardware::_getAssociatedMacAddresses(
        snmp           => $snmp,
        address2port   => '.1.3.6.1.2.1.17.4.3.1.2',
        port2interface => '.1.3.6.1.2.1.17.1.4.1.2',
    );

    cmp_deeply(
        $mac_addresses,
        $test->[1],
        $test->[2]
    );
}

foreach my $test (@mac_addresses_addition_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    FusionInventory::Agent::Tools::Hardware::_setAssociatedMacAddresses(
        snmp  => $snmp,
        ports => $test->[1],
    );

    cmp_deeply(
        $test->[1],
        $test->[2],
        $test->[3]
    );
}

foreach my $test (@trunk_ports_extraction_tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    my $trunk_ports = FusionInventory::Agent::Tools::Hardware::_getTrunkPorts(
        snmp  => $snmp,
    );

    cmp_deeply(
        $trunk_ports,
        $test->[1],
        $test->[2]
    );
}

my $oid = '0.1.2.3.4.5.6.7.8.9';
is(
    FusionInventory::Agent::Tools::Hardware::_getElement($oid, 0),
    0,
    'index 0'
);
is(
    FusionInventory::Agent::Tools::Hardware::_getElement($oid, -1),
    9,
    'index -1'
);
is(
    FusionInventory::Agent::Tools::Hardware::_getElement($oid, -2),
    8,
    'index -2'
);
cmp_deeply(
    [ FusionInventory::Agent::Tools::Hardware::_getElements($oid, 0, 3) ],
    [ qw/0 1 2 3/ ],
    'getElements with index 0 to 3'
);
cmp_deeply(
    [ FusionInventory::Agent::Tools::Hardware::_getElements($oid, -4, -1) ],
    [ qw/6 7 8 9/ ],
    'getElements with index -4 to -1'
);
