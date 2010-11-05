#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'freebsd-6.2' => [
        {
            NAME         => 'VIA C7',
            SERIAL       => 'A9060000FFBBC9A7',
            MANUFACTURER => 'VIA',
            SPEED        => '2000',
            THREAD       => 1
        }
    ],
    'freebsd-8.1' => [
        {
            NAME         => 'Intel(R) Core(TM) i5 CPU       M 430  @ 2.27GHz',
            SERIAL       => '52060200FFFBEBBF',
            MANUFACTURER => 'Intel(R) Corporation',
            SPEED        => '2266',
            THREAD       => 4
        }
    ],
    'openbsd-3.7' => [
        {
            NAME         => 'Pentium II',
            SERIAL       => '52060000FFF98301',
            MANUFACTURER => 'Intel',
            SPEED        => '500',
            THREAD       => 1,
        }
    ],
    'openbsd-3.8' => [
        {
            NAME         => 'Xeon',
            SERIAL       => '430F0000FFFBEBBF',
            MANUFACTURER => 'Intel',
            SPEED        => '3600',
            THREAD       => 1,
        },
        {
            NAME         => 'Xeon',
            SERIAL       => '0000000000000000',
            MANUFACTURER => 'Intel',
            SPEED        => '3600',
            THREAD       => 1,
        }
    ],
    'openbsd-4.5' => [
        {
            NAME         => 'Pentium 4',
            SERIAL       => '290F0000FFFBEBBF',
            MANUFACTURER => 'Intel',
            SPEED        => '3200',
            THREAD       => 1
        },
        {
            NAME         => 'Pentium 4',
            SERIAL       => '0000000000000000',
            MANUFACTURER => 'Intel',
            SPEED        => '3200',
            THREAD       => 1
        }
    ],
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();
foreach my $test (keys %tests) {
    my $file = "resources/dmidecode/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::OS::BSD::CPU::_getCPUsFromDmidecode($logger, $file);
    is_deeply(\@cpus, $tests{$test}, $test);
}
