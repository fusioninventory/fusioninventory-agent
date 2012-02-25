#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::MacOS::Videos;

my %tests = (
    '10.4-powerpc' => {
        MONITORS => [
            {
                DESCRIPTION  => 'ASUS VH222',
                CAPTION      => 'ASUS VH222'
            }
        ],
        VIDEOS => [
            {
                NAME       => 'NVIDIA GeForce 6600',
                RESOLUTION => '1360x768',
                CHIPSET    => 'GeForce 6600',
                MEMORY     => '256',
                PCISLOT    => 'SLOT-1'
            }
        ]
    },
    '10.5-powerpc' => 
        {
        MONITORS => [
            {
                DESCRIPTION  => 'ASUS VH222',
                CAPTION      => 'ASUS VH222'
            }
        ],
        VIDEOS => [
            {
                NAME       => 'NVIDIA GeForce 6600',
                RESOLUTION => '1680x1050',
                CHIPSET    => 'GeForce 6600',
                MEMORY     => '256',
                PCISLOT    => 'SLOT-1'
            }
        ]
    },
    '10.6-intel' => {
        MONITORS => [
            {
                DESCRIPTION  => 'iMac',
                CAPTION      => 'iMac'
            }
        ],
        VIDEOS => [
            {
                NAME       => 'ATI Radeon HD 2600 Pro',
                RESOLUTION => '1920x1200',
                CHIPSET    => 'ATI,RadeonHD2600',
                MEMORY     => '256',
                PCISLOT    => undef
            }
        ]
    },
    '10.6.6-intel' => {
        MONITORS => [
            {
                DESCRIPTION  => 'Color LCD',
                CAPTION      => 'Color LCD'
            }
        ],
        VIDEOS => [
            {
                NAME       => 'Intel GMA 950',
                RESOLUTION => '1280x800',
                CHIPSET    => 'GMA 950',
                MEMORY     => '64',
                PCISLOT    => undef
            }
        ]
    }
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test";
    my %displays = FusionInventory::Agent::Task::Inventory::Input::MacOS::Videos::_getDisplays(file => $file);
    is_deeply(\%displays, $tests{$test}, $test);
}
