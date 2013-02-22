#!/usr/bin/perl

use strict;
use warnings;

use Clone qw(clone);
use Test::Deep;
use Test::More;

use FusionInventory::Agent::Manufacturer;
use FusionInventory::Agent::Manufacturer::Cisco;
use FusionInventory::Agent::Task::NetInventory;

# each item is an arrayref of three elements:
# - input data structure (ports list)
# - expected resulting data structure
# - test explication
my @trunk_ports_tests = (
    [
        {},
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
        {},
        {
            24 => {
                CONNECTIONS => {
                    CONNECTION => {
                        IP       => '192.168.20.139',
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
    scalar @connected_devices_mac_addresses_tests * 2 +
    scalar @cisco_connected_devices_mac_addresses_tests * 2;

my $walks = {
    cdpCacheDevicePort => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.7'
    },
    cdpCacheVersion => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.5'
    },
    cdpCacheDeviceId => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.6'
    },
    cdpCachePlatform => {
        OID => '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    },
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
    vlanTrunkPortDynamicStatus => {
        '1.2.0' => 1,
        '1.2.1' => 0,
        '1.2.2' => 1
    },
    cdpCacheAddress => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.4.24.7' => '0xc0a8148b'
    },
    cdpCacheDevicePort => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.7.24.7' => 'Port 1'
    },
    cdpCacheVersion => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.5.24.7' => '7.4.9c'
    },
    cdpCacheDeviceId => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.6.24.7' => 'SIPE05FB981A7A7'
    },
    cdpCachePlatform => {
        '.1.3.6.1.4.1.9.9.23.1.2.1.1.8.24.7' => 'Cisco IP Phone SPA508G'
    },
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

my $cisco_results = {
    VLAN => {
        1 => {
            dot1dTpFdbPort => {
                '.1.3.6.1.2.1.17.4.3.1.2.0.28.246.197.100.25' => 2307,
            },
            dot1dTpFdbAddress => {
                '.1.3.6.1.2.1.17.4.3.1.1.0.28.246.197.100.25' => '0x001CF6C56419',
            },
            dot1dBasePortIfIndex => {
                '.1.3.6.1.2.17.1.4.1.2.2307' => 0,
            }
        }
    }
};

# direct tests
foreach my $test (@trunk_ports_tests) {
    my $ports = clone($test->[0]);
    FusionInventory::Agent::Manufacturer::setTrunkPorts(
        results => $results, ports => $ports, walks => $walks
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@connected_devices_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Manufacturer::setConnectedDevices(
        results => $results, ports => $ports, walks => $walks
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Manufacturer::setConnectedDevicesMacAddresses(
        results => $results, ports => $ports, walks => $walks
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (direct)',
    );
}

foreach my $test (@cisco_connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Manufacturer::Cisco::setConnectedDevicesMacAddresses(
        results => $cisco_results, ports => $ports, walks => $walks, vlan_id => 1
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

    FusionInventory::Agent::Task::NetInventory::_setTrunkPorts(
        'Cisco', $results, $ports
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}

foreach my $test (@connected_devices_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Task::NetInventory::_setConnectedDevices(
        'Cisco', $results, $ports, $walks
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}

foreach my $test (@connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Task::NetInventory::_setConnectedDevicesMacAddresses(
        'ProCurve', $results, $ports, $walks
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}

foreach my $test (@cisco_connected_devices_mac_addresses_tests) {
    my $ports = clone($test->[0]);

    FusionInventory::Agent::Task::NetInventory::_setConnectedDevicesMacAddresses(
        'Cisco', $cisco_results, $ports, $walks, 1
    );

    cmp_deeply(
        $ports,
        $test->[1],
        $test->[2] . ' (indirect)',
    );
}
