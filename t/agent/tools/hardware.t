#!/usr/bin/perl

use strict;
use warnings;

use Clone qw(clone);
use Test::Deep;
use Test::More;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Hardware::Generic;

# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @trunk_ports_tests = (
    [
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
        'trunk ports'
    ]
);

# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @connected_devices_tests = (
    [
        {
            24 => {},
        },
        {
            24 => {
                CONNECTIONS => {
                    CONNECTION => {
                        IP       => '192.168.20.139',
                        MAC      => 'E0:5F:B9:81:A7:A7',
                        IFDESCR  => 'Port 1',
                        SYSDESCR => '7.4.9c',
                        SYSNAME  => 'SIPE05FB981A7A7',
                        MODEL    => 'Cisco IP Phone SPA508G',
                    },
                    CDP => 1,
                },
            },
        },
        'connected devices'
    ],
);

# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @connected_devices_mac_addresses_tests = (
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
        'mac addresses'
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
        'mac addresses, CDP exception'
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
        'mac addresses, same address exception'
    ],
);


my @method1_connected_devices_mac_addresses_tests = (
    [
        {
            865 => {
                MAC => 'X',
                IFNAME => 865
            }
        },
        {
            865 => {
                CONNECTIONS => {
                    CONNECTION => {
                        MAC => [ 'e8:9a:8f:b0:11:71' ]
                    }
                },
                IFNAME => 865,
                MAC => 'X'
            }
        },
        'mac addresses found'
    ]
);


# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @cisco_connected_devices_mac_addresses_tests = (
    [
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
        'mac addresses, cisco'
    ],
    [
        {
            0 => {
                CONNECTIONS => {
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                    CDP => 1,
                },
                MAC => 'X',
            }
        },
        'mac addresses, CDP exception, cisco'
    ],
    [
        {
            0 => {
                MAC => '00:1C:F6:C5:64:19',
            }
        },
        {
            0 => {
                CONNECTIONS => {
                },
                MAC => '00:1C:F6:C5:64:19',
            }
        },
        'mac addresses, same address exception, cisco'
    ],
);

plan tests =>
    scalar @trunk_ports_tests * 2 +
    scalar @connected_devices_tests * 2 +
    scalar @connected_devices_mac_addresses_tests +
    scalar @cisco_connected_devices_mac_addresses_tests +
    2;

my $model = {
    oids => {
        cdpCacheAddress            => '.1.3.6.1.4.1.9.9.23.1.2.1.1.4',
        cdpCacheVersion            => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5',
        cdpCacheDeviceId           => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6',
        cdpCacheDevicePort         => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7',
        cdpCachePlatform           => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8',
        dot1dTpFdbPort             => '.1.3.6.1.2.1.17.4.3.1.2',
        dot1dTpFdbAddress          => '.1.3.6.1.2.1.17.4.3.1.1',
        dot1dBasePortIfIndex       => '.1.3.6.1.2.1.17.1.4.1.2',
        vlanTrunkPortDynamicStatus => '.1.3.6.1.4.1.9.9.46.1.6.1.1.14'
    }
};

my $snmp = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7'        => [ 'STRING', '0xc0a8148b' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7'        => [ 'STRING', 'Port 1' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7'        => [ 'STRING', '7.4.9c' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7'        => [ 'STRING', 'SIPE05FB981A7A7' ],
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7'        => [ 'STRING', 'Cisco IP Phone SPA508G' ],
        '.1.3.6.1.2.1.17.4.3.1.2.0.0.116.210.9.106' => [ 'INTEGER', 52 ],
        '.1.3.6.1.2.1.17.4.3.1.1.0.0.116.210.9.106' => [ 'STRING', '0x000074D2096A' ],
        '.1.3.6.1.2.1.17.1.4.1.2.52'                => [ 'INTEGER', 52 ],
        '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.0'      => [ 'INTEGER', 1  ],
        '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.1'      => [ 'INTEGER', 0  ],
        '.1.3.6.1.4.1.9.9.46.1.6.1.1.14.1.2.2'      => [ 'INTEGER', 1  ]
    }
);

my $method1_snmp = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.17.1.4.1.2.644' => [ 'INTEGER', '865' ],
        '.1.3.6.1.2.1.17.7.1.2.2.1.2.27.232.154.143.176.17.113' => [ 'INTEGER', '644' ],
    }
);

my $cisco_snmp = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.17.4.3.1.2.0.28.246.197.100.25' => [ 'INTEGER', 2307 ],
        '.1.3.6.1.2.1.17.4.3.1.1.0.28.246.197.100.25' => [ 'STRING', '0x001CF6C56419' ],
        '.1.3.6.1.2.1.17.1.4.1.2.2307'                => [ 'INTEGER', 0 ],
    }
);

# direct tests
foreach my $test (@trunk_ports_tests) {
    my $ports = clone($test->[0]);
    FusionInventory::Agent::Tools::Hardware::Generic::setTrunkPorts(
        snmp => $snmp, ports => $ports, model => $model
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@connected_devices_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevices(
        snmp => $snmp, ports => $ports, model => $model
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
        snmp => $snmp, ports => $ports, model => $model
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@method1_connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
        snmp => $method1_snmp, ports => $ports
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@cisco_connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::Generic::setConnectedDevicesMacAddresses(
        snmp => $cisco_snmp, ports => $ports, model => $model
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

# indirect tests
foreach my $test (@trunk_ports_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::_setTrunkPorts(
        'Cisco', $snmp, $model, $ports
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}

foreach my $test (@connected_devices_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Tools::Hardware::_setConnectedDevices(
        'Cisco', $snmp, $model, $ports
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}

## getDeviceBaseInfo()
$snmp = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
    }
);

my %device = getDeviceBaseInfo($snmp);
cmp_deeply(
    \%device,
    { DESCRIPTION => 'foo' },
    'getDeviceBaseInfo() with no sysobjectid'
);

$snmp = FusionInventory::Agent::SNMP::Mock->new(
    hash => {
        '.1.3.6.1.2.1.1.1.0'        => [ 'STRING', 'foo' ],
        '.1.3.6.1.2.1.1.2.0'        => [ 'STRING', '.1.3.6.1.4.1.45' ],
    }
);

%device = getDeviceBaseInfo($snmp);
cmp_deeply(
    \%device,
    { DESCRIPTION => 'foo', TYPE => 'NETWORKING', MANUFACTURER => 'Nortel' },
    'getDeviceBaseInfo() with sysobjectid'
);
