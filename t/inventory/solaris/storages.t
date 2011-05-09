#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::OS::Solaris::Storages;

my %tests = (
    'sample1' => [
        {
            NAME         => 'c8t60060E80141A420000011A420000300Bd0',
            DISKSIZE     => 64424,
            FIRMWARE     => '5009',
            MANUFACTURER => 'HITACHI',
            MODEL        => 'OPEN-V'
        },
    ],
    'sample2' => [
        {
            NAME         => 'sd0',
            DISKSIZE     => 73400,
            FIRMWARE     => 'PQ08',
            MANUFACTURER => 'HITACHI',
            MODEL        => 'DK32EJ72NSUN72G',
            SERIALNUMBER => '43W14Z080040A34E',
            DESCRIPTION  => 'S/N:43W14Z080040A34E'
        },
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/solaris/iostat/$test";
    my @storages = FusionInventory::Agent::Task::Inventory::OS::Solaris::Storages::_getStorages(file => $file);
    is_deeply(\@storages, $tests{$test}, $test);
}
