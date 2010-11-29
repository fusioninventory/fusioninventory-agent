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
            ID           => 'A9 06 00 00 FF BB C9 A7',
            SERIAL       => undef,
            MANUFACTURER => 'VIA',
            SPEED        => '2000',
            THREAD       => 1
        }
    ],
    'freebsd-8.1' => [
        {
            NAME         => 'Intel(R) Core(TM) i5 CPU       M 430  @ 2.27GHz',
            ID           => '52 06 02 00 FF FB EB BF',
            SERIAL       => undef,
            MANUFACTURER => 'Intel(R) Corporation',
            SPEED        => '2266',
            THREAD       => 4
        }
    ],
    'openbsd-3.7' => [
        {
            NAME         => 'Pentium II',
            ID           => '52 06 00 00 FF F9 83 01',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            SPEED        => '500',
            THREAD       => 1,
        }
    ],
    'openbsd-3.8' => [
        {
            NAME         => 'Xeon',
            ID           => '43 0F 00 00 FF FB EB BF',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            SPEED        => '3600',
            THREAD       => 1,
        },
        {
            NAME         => 'Xeon',
            ID           => '00 00 00 00 00 00 00 00',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            SPEED        => '3600',
            THREAD       => 1,
        }
    ],
    'openbsd-4.5' => [
        {
            NAME         => 'Pentium 4',
            ID           => '29 0F 00 00 FF FB EB BF',
            SERIAL       => undef,
            MANUFACTURER => 'Intel',
            SPEED        => '3200',
            THREAD       => 1
        },
        {
            NAME         => 'Pentium 4',
            ID           => '00 00 00 00 00 00 00 00',
            SERIAL       => undef,
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
