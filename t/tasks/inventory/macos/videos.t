#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::MacOS::Videos;

my %tests = (
    '10.6.5-dual-monitor' => {
        MONITORS => [
            {
                CAPTION     => 'E2441'
            },
            {
                CAPTION     => 'E2441_0'
            }
        ],
        VIDEOS => [
            {
                NAME        => 'ATI Radeon HD 5770',
                RESOLUTION  => '1920x1080',
                CHIPSET     => 'ATI Radeon HD 5770',
                MEMORY      => '1024',
                PCISLOT     => 'Slot-1'
            }
        ]
    },
    'dual-display-#475' => {
        MONITORS => [
            {
                DESCRIPTION => 'Built-In Retina LCD',
                CAPTION     => 'Color LCD'
            }
        ],
        VIDEOS => [
            {
                NAME        => 'Intel HD Graphics 530',
                CHIPSET     => 'Intel HD Graphics 530',
                MEMORY      => '1536',
                PCISLOT     => 'Built-In'
            },
            {
                NAME        => 'Radeon Pro 450',
                RESOLUTION  => '2880x1800',
                CHIPSET     => 'AMD Radeon Pro 450',
                MEMORY      => '2048',
                PCISLOT     => 'PCIe'
            }
        ]
    },
    'asus-geforce-gt-730' => {
        MONITORS => [
            {
                CAPTION     => 'DELL SE2416H',
                SERIAL      => 'P7HT871G1H9L'
            }
        ],
        VIDEOS => [
            {
                MEMORY      => '1024',
                PCISLOT     => 'PCIe',
                RESOLUTION  => '1920x1080',
                CHIPSET     => 'Asus GeForce GT 730',
                NAME        => 'Asus GeForce GT 730'
            }
        ]
    }
);

plan tests => (2 * scalar keys %tests) + 1;

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test";
    my %displays = FusionInventory::Agent::Task::Inventory::MacOS::Videos::_getDisplays(file => $file);
    cmp_deeply(
        [ sort { compare_monitor() } @{$displays{MONITORS}} ],
        [ sort { compare_monitor() } @{$tests{$test}{MONITORS}} ],
        "$test monitors"
    );
    cmp_deeply(
        [ sort { compare_video() } @{$displays{VIDEOS}} ],
        [ sort { compare_video() } @{$tests{$test}{VIDEOS}} ],
        "$test videos"
    );
}

sub compare_video {
    return
        $a->{NAME} cmp $b->{NAME};
}

sub compare_monitor {
    return
        $a->{CAPTION} cmp $b->{CAPTION};
}
