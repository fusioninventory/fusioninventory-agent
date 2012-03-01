#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios;

my %showrev_tests = (
    'SPARC-1' => {
        '    breakpoint-trap' => '0000007f',
        '    banner-name' => '\'Sun',
        '    compatible' => '\'SUNW,Serengeti\'',
        '    scsi-initiator-id' => '00000007',
        'Release' => '5.10',
        '    name' => '\'SUNW,Sun-Fire\'',
        'Memory size' => '16384',
        '    #size-cells' => '00000002',
        'System Configuration' => 'Sun',
        'Hostname' => '157501s021plc',
        'Kernel version' => 'SunOS',
        'Kernel architecture' => 'sun4u',
        'Hardware provider' => 'Sun_Microsystem',
        '    node#' => '00000000',
        '    newio-addr' => '00000001',
        'Domain' => 'be.cnamts.fr',
        'Application architecture' => 'sparc',
        '    stick-frequency' => '00bebc20',
        'Hostid' => '83249bbf',
        '    clock-frequency' => '08f0d180',
        '    idprom' => '01840014.4f4162cb.45255cf4.4162cb16.55555555.55555555.55555555.55555555',
        '    device_type' => '\'gptwo\''
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
        '  Manufacturer' => 'Sun',
        'Application architecture' => 'i386',
        '  Serial Number' => 'R00T34E0009',
        '  Product' => 'Sun',
        'Hostid' => '403100b',
        'Release' => '5.10',
        '  Wake-Up Event' => '0x6',
        '  UUID' => 'be1630df-d130-41a4-be32-fd28bb4bd1ac',
        '  Version' => '00'
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

plan tests => scalar keys %showrev_tests;

foreach my $test (keys %showrev_tests) {
    my $file   = "resources/solaris/showrev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios::_parseShowRev(file => $file);
    is_deeply($result, $showrev_tests{$test}, "showrev parsing: $test");
}
