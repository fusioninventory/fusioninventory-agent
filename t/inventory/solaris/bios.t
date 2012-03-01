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

plan tests => scalar keys %showrev_tests;

foreach my $test (keys %showrev_tests) {
    my $file   = "resources/solaris/showrev/$test";
    my $result = FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios::_parseShowRev(file => $file);
    is_deeply($result, $showrev_tests{$test}, "showrev parsing: $test");
}
