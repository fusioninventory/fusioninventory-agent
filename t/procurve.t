#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Task::NetInventory::Manufacturer::Procurve;

# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @devices_mac_addresses_tests = (
    [
        {
            52 => {
                MAC => 'X',
            }
        },
        {
            52 => {
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ '00:00:74:D2:09:6A' ]
                    }
                },
                MAC => 'X',
            }
        },
        'connected devices mac address retrieval'
    ],
    [
        {
            52 => {
                CONNECTIONS => {
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        {
            52 => {
                CONNECTIONS => {
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        'connected devices mac address retrieval, connected device found by CDP'
    ],
    [
        {
            52 => {
                MAC => '00:00:74:D2:09:6A',
            }
        },
        {
            52 => {
                CONNECTIONS => {
                },
                MAC => '00:00:74:D2:09:6A',
            }
        },
        'connected devices mac address retrieval, same mac address as the port'
    ],
);

plan tests => 
    scalar @devices_mac_addresses_tests;

my $walks = {
    dot1dTpFdbPort => {
        OID => '.1.3.6.1.2.1.17.4.3.1.2'
    },
    dot1dTpFdbAddress => {
        OID => '.1.3.6.1.2.1.17.4.3.1.1'
    },
    dot1dBasePortIfIndex => {
        OID => '.1.3.6.1.2.17.1.4.1.2'
    },
};

my $results = {
    dot1dTpFdbPort => {
        '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => 52,
    },
    dot1dTpFdbAddress => {
        '.1.3.6.1.2.1.17.4.3.1.1.0.0.116.210.9.106' => '0x000074D2096A'
    },
    dot1dBasePortIfIndex => {
        '.1.3.6.1.2.17.1.4.1.2.52' => 52,
    }
};

foreach my $test (@devices_mac_addresses_tests) {
    FusionInventory::Agent::Task::NetInventory::Manufacturer::Procurve::setConnectedDevicesMacAddress(
        results => $results, ports => $test->[0], walks => $walks
    );

    is_deeply(
        $test->[0],
        $test->[1],
        $test->[2],
    );
}
