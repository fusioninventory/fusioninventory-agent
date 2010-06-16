#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;
use Test::More;
use FindBin;

my %tests = (
    'dell-xt2' => [
        {
            NAME         => 'sda',
            FIRMWARE     => 'VBM24DQ1',
            DISKSIZE     => 122104,
            MANUFACTURER => 'ATA',
            MODEL        => 'SAMSUNG SSD PM80',
            SERIALNUMBER => 'SAMSUNG_SSD_PM800_TM_128GB_DFW1W11002SE002B3117',
            TYPE         => 'disk'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "$FindBin::Bin/../resources/hal/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::parseLshal($file, '<');
    is_deeply($tests{$test}, $results, $test);
}
