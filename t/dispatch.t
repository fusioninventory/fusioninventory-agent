#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Task::NetInventory;

# each item is an arrayref of three elements:
# - input parameters (sysdescr, results, ports list)
# - expected resulting ports list
# - test explication
my @trunk_ports_tests = (
    [
        [ 'unknown', undef, undef ],
        undef,
        'unknown vendor'
    ],
    [
        [ 'Cisco',
            {
                vlanTrunkPortDynamicStatus => {
                    '1.2.0' => 1,
                    '1.2.1' => 0,
                    '1.2.2' => 1
                }
            },
            {
            }
        ],
        {
            0 => {
                TRUNK => 1
            },
            1 => {
                TRUNK => 0
            },
            2 => {
                TRUNK => 1
            },
        },
        'cisco'
    ]
);

my @connected_devices_tests = (
    [
        [ 'unknown', undef, undef, undef ],
        undef,
        'unknown vendor'
    ]
);

plan tests => 
    scalar @trunk_ports_tests +
    scalar @connected_devices_tests;

foreach my $test (@trunk_ports_tests) {
    FusionInventory::Agent::Task::NetInventory::_setTrunkPorts(
        @{$test->[0]}
    );

    is_deeply(
        $test->[0]->[2],
        $test->[1],
        $test->[2],
    );
}

foreach my $test (@connected_devices_tests) {
    FusionInventory::Agent::Task::NetInventory::_setConnectedDevices(
        @{$test->[0]}
    );

    is_deeply(
        $test->[0]->[2],
        $test->[1],
        $test->[2],
    );
}
