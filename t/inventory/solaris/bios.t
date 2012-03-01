#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios;

my %showrev_tests = (
    'SPARC-1' => {
        'Release' => '5.10',
        'Hostname' => '157501s021plc',
        'Kernel version' => 'SunOS',
        'Kernel architecture' => 'sun4u',
        'Hardware provider' => 'Sun_Microsystem',
        'Domain' => 'be.cnamts.fr',
        'Application architecture' => 'sparc',
        'Hostid' => '83249bbf',
    },
    'SPARC-2' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'mysunserver',
        'Hardware provider' => 'Sun_Microsystems',
        'Kernel architecture' => 'sun4v',
        'Application architecture' => 'sparc',
        'Hostid' => 'mabox'
    },
    'x86-1' => {
        'Kernel version' => 'SunOS',
        'Hostname' => 'stlaurent',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '403100b',
        'Release' => '5.10',
    },
    'x86-2' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'mamachine',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '7c31a88'
    },
    'x86-3' => {
        'Kernel version' => 'SunOS',
        'Release' => '5.10',
        'Hostname' => 'plop',
        'Kernel architecture' => 'i86pc',
        'Application architecture' => 'i386',
        'Hostid' => '7c31a36'
    }
);

my %smbios_tests = (
    'x86-1' => {
        'Version' => '00',
        'SKU Number' => ' ',
        'Serial Number' => 'R00T34E0009',
        'Product' => 'Sun Fire V40z',
        'Manufacturer' => 'Sun Microsystems, Inc.',
        'UUID' => 'be1630df-d130-41a4-be32-fd28bb4bd1ac',
        'Wake-Up Event' => '0x6 (power switch)'
    },
    'x86-3' => {
        'Flags' => '0x9',
        'Serial Number' => 'QSDH1234567',
        'Family' => ' ',
        'Type' => '1 (KCS: Keyboard Controller Style)',
        'ROM Size' => '8388608 bytes',
        'Release Date' => '07/12/2009',
        'Product' => 'S7000FC4UR',
        'Manufacturer' => 'TRANSTEC',
        'Characteristics' => '0x15c099a80',
        'Version Number' => '0.0',
        'Chassis Height' => '1u',
        'Power Supply State' => '0x3 (safe)',
        'Lock Present' => 'N',
        'Interrupt Number' => '0',
        'Version' => 'E10476-011',
        'Version String' => 'SFC4UR.86B.01.00.0029.071220092126',
        'Board Type' => '0xa (motherboard)',
        'i2c Bus Slave Address' => '0x20',
        'SKU Number' => '6I012345TF',
        'Vendor' => 'Intel Corporation',
        'Image Size' => '98304 bytes',
        'Chassis Type' => '0x17 (rack mount chassis)',
        'Power Cords' => '1',
        'Address Segment' => '0xe800',
        'BMC Base Address' => '0xca2',
        'Boot-Up State' => '0x3 (safe)',
        'UUID' => '4b713db6-6d40-11dd-b32c-000123456789',
        'Chassis' => '0',
        'NV Storage Device Bus ID' => '0xffffffff',
        'BMC IPMI Version' => '2.0',
        'Element Records' => '0',
        'Thermal State' => '0x3 (safe)',
        'Register Spacing' => '1',
        'Asset Tag' => '6I012345TF',
        'Characteristics Extension Byte 2' => '0x7',
        'Characteristics Extension Byte 1' => '0x33',
        'Embedded Ctlr Firmware Version Number' => '0.0',
        'OEM Data' => '0x81581cf8',
        'Wake-Up Event' => '0x6 (power switch)'
      }
);

my %prtconf_tests = (
    'SPARC-1' => {
        'compatible' => 'SUNW,Serengeti',
        'device_type' => 'gptwo',
        'banner-name' => 'Sun Fire E6900',
        'name' => 'SUNW,Sun-Fire'
    }
);

plan tests => 
    (scalar keys %showrev_tests) +
    (scalar keys %smbios_tests)  +
    (scalar keys %prtconf_tests);

foreach my $test (keys %showrev_tests) {
    my $file   = "resources/solaris/showrev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios::_parseShowRev(file => $file);
    is_deeply($result, $showrev_tests{$test}, "showrev parsing: $test");
}

foreach my $test (keys %smbios_tests) {
    my $file   = "resources/solaris/smbios/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios::_parseSmbios(file => $file);
    is_deeply($result, $smbios_tests{$test}, "smbios parsing: $test");
}

foreach my $test (keys %prtconf_tests) {
    my $file   = "resources/solaris/prtconf/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios::_parsePrtconf(file => $file);
    is_deeply($result, $prtconf_tests{$test}, "prtconf parsing: $test");
}
