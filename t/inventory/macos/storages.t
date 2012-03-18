#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::MacOS::Storages;

my %tests = (
    '10.4-powerpc' => [
        {
            NAME         => 'HL-DT-ST DVD-RW GWA-4165B',
            FIRMWARE     => 'C006',
            TYPE         => 'ATA',
            SERIAL       => 'B6FD7234EC63',
            DISKSIZE     => undef,
            MANUFACTURER => 'HL-DT-ST DVD-RW GWA-4165B',
            MODEL        => '',
            DESCRIPTION  => 'CD-ROM Drive'
        }
    ],
    '10.5-powerpc' => [
        {
            NAME         => 'HL-DT-ST DVD-RW GWA-4165B',
            FIRMWARE     => 'C006',
            TYPE         => 'ATA',
            SERIAL       => 'B6FD7234EC63',
            DISKSIZE     => undef,
            MANUFACTURER => 'HL-DT-ST DVD-RW GWA-4165B',
            MODEL        => '',
            DESCRIPTION  => 'CD-ROM Drive'
        },
        {
            NAME         => 'Flash Disk',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '110074973765',
            DISKSIZE     => 2007,
            MANUFACTURER => 'Flash Disk',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        },
        {
            NAME         => 'DataTraveler 2.0',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '89980116200801151425097A',
            DISKSIZE     => 3850,
            MANUFACTURER => 'DataTraveler 2.0',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        }
    ],
    '10.6-intel' => [
        {
            NAME         => 'MATSHITADVD-R   UJ-875',
            FIRMWARE     => 'DB09',
            TYPE         => 'ATA',
            SERIAL       => '            fG424F9E',
            DISKSIZE     => undef,
            MANUFACTURER => 'Matshita',
            MODEL        => 'DVD-R   UJ-875',
            DESCRIPTION  => 'CD-ROM Drive'
        },
        {
            NAME         => 'Flash Disk      ',
            FIRMWARE     => undef,
            TYPE         => 'USB',
            SERIAL       => '110074973765',
            DISKSIZE     => 2160,
            MANUFACTURER => 'Flash Disk      ',
            MODEL        => undef,
            DESCRIPTION  => 'Disk drive'
        }
    ],
    '10.6.6-intel' => [
        {
            NAME         => 'MATSHITACD-RW  CW-8221',
            FIRMWARE     => 'GA0J',
            TYPE         => 'ATA',
            SERIAL       => undef,
            DISKSIZE     => undef,
            MANUFACTURER => 'Matshita',
            MODEL        => 'CD-RW  CW-8221',
            DESCRIPTION  => 'CD-ROM Drive'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test";
    my @storages = FusionInventory::Agent::Task::Inventory::Input::MacOS::Storages::_getStorages(file => $file);
    is_deeply(\@storages, $tests{$test}, $test);
}
