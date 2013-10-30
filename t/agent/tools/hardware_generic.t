#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware::Generic;

# each item is an arrayref of four elements:
# - raw SNMP values
# - input ports list
# - output ports list
# - test explication
my @cdp_info_tests = (
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        {
            24 => {}
        },
        {
            24 => {
                CONNECTIONS => {
                    CDP => 1,
                    CONNECTION => {
                        MAC      => 'E0:5F:B9:81:A7:A7',
                        SYSDESCR => '7.4.9c',
                        IFDESCR  => 'Port 1',
                        MODEL    => 'Cisco IP Phone SPA508G',
                        IP       => '192.168.20.139',
                        SYSNAME  => 'SIPE05FB981A7A7'
                     }
                 }
             }
        },
        'connected devices info extraction through CDP'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        },
        {
            24 => {}
        },
        {
            24 => {}
        },
        'connected devices info extraction through CDP, missing CDP cache version'
    ],
    [
        {
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => [ 'STRING', '0xc0a8148b' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => [ 'STRING', '7.4.9c' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => [ 'STRING', 'SIPE05FB981A7A7' ],
            '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => [ 'STRING', 'Port 1' ],
        },
        {
            24 => {}
        },
        {
            24 => {}
        },
        'connected devices info extraction through CDP, missing CDP cache platform'
    ],
);

# each item is an arrayref of four elements:
# - raw SNMP values
# - input ports list
# - output ports list
# - test explication
my @mac_addresses_tests = (
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.28.246.197.100.25' => [ 'INTEGER', 2307 ],
            '.1.3.6.1.2.1.17.4.3.1.1.0.28.246.197.100.25' => [ 'STRING', '0x001CF6C56419' ],
            '.1.3.6.1.2.1.17.1.4.1.2.2307'                => [ 'INTEGER', 0 ],
        },
        {
            0 => {
                MAC => 'X',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ '00:1C:F6:C5:64:19' ]
                    }
                },
                MAC => 'X',
            }
        },
        'connected devices mac addresses extraction, first dataset'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.1.0.0.116.210.9.106' => [ 'STRING', '0x000074D2096A' ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
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
        'connected devices mac addresses extraction, second dataset'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.1.0.0.116.210.9.106' => [ 'STRING', '0x000074D2096A' ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
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
        'connected devices mac addresses extraction, already processed connection'
    ],
    [
        {
            '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
            '.1.3.6.1.2.1.17.4.3.1.1.0.0.116.210.9.106' => [ 'STRING', '0x000074D2096A' ],
            '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        },
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
        'connected devices mac addresses extraction, same address connection'
    ],
);

# each item is an arrayref of four elements:
# - raw SNMP values
# - input ports list
# - output ports list
# - test explication
my @trunk_ports_tests = (
    [
        {
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.0' => [ 'INTEGER', 1  ],
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.1' => [ 'INTEGER', 0  ],
            '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.2' => [ 'INTEGER', 1  ]
        },
        {
            0 => {},
            1 => {},
            2 => {},
        },
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
        'trunk ports extraction'
    ]
);

plan tests => 
    scalar @cdp_info_tests      +
    scalar @mac_addresses_tests +
    scalar @trunk_ports_tests;

my $cdp_model = {
    oids => {
        cdpCacheAddress    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.4',
        cdpCacheVersion    => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5',
        cdpCacheDeviceId   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6',
        cdpCacheDevicePort => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7',
        cdpCachePlatform   => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    }
};

foreach my $test (@cdp_info_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::_setConnectedDevicesInfoCDP(
        snmp  => $snmp,
        model => $cdp_model,
        ports => $test->[1],
    );

    cmp_deeply(
        $test->[1],
        $test->[2],
        $test->[3]
    );
}

my $mac_addresses_model = {
    oids => {
        dot1dTpFdbPort             => '.1.3.6.1.2.1.17.4.3.1.2',
        dot1dTpFdbAddress          => '.1.3.6.1.2.1.17.4.3.1.1',
        dot1dBasePortIfIndex       => '.1.3.6.1.2.1.17.1.4.1.2',
    }
};

foreach my $test (@mac_addresses_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
        snmp  => $snmp,
        model => $mac_addresses_model,
        ports => $test->[1],
    );

    cmp_deeply(
        $test->[1],
        $test->[2],
        $test->[3]
    );
}

my $trunk_model = {
    oids => {
        vlanTrunkPortDynamicStatus => '.1.3.6.1.4.1.9.9.46.1.6.1.1.14'
    }
};

foreach my $test (@trunk_ports_tests) {
    my $snmp  = FusionInventory::Agent::SNMP::Mock->new(hash => $test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setTrunkPorts(
        snmp  => $snmp,
        model => $trunk_model,
        ports => $test->[1],
    );

    cmp_deeply(
        $test->[1],
        $test->[2],
        $test->[3]
    );
}
