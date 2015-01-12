#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Deep qw(cmp_deeply);
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Message::Inbound;

my %tests = (
    netdiscovery => [
        {
            task    => 'NetDiscovery',
            options =>  {
                RANGEIP => [
                    {
                        ID      => '1',
                        ENTITY  => '15',
                        IPSTART => '192.168.0.1',
                        IPEND   => '192.168.0.254'
                    },
                ],
                AUTHENTICATION => [
                    {
                        ID             => '1',
                        AUTHPROTOCOL   => '',
                        PRIVPROTOCOL   => '',
                        USERNAME       => '',
                        AUTHPASSPHRASE => '',
                        VERSION        => '1',
                        COMMUNITY      => 'public',
                        PRIVPASSPHRASE => ''
                    },
                    {
                        ID             => '2',
                        AUTHPROTOCOL   => '',
                        PRIVPROTOCOL   => '',
                        USERNAME       => '',
                        AUTHPASSPHRASE => '',
                        VERSION        => '2c',
                        COMMUNITY      => 'public',
                        PRIVPASSPHRASE => ''
                    }
                ],
                PARAM => [
                    {
                        CORE_DISCOVERY    => '1',
                        PID               => '1280265592/024',
                        THREADS_DISCOVERY => '10'
                    }
                ]
            }
        }
    ],
    netinventory1 => [
        {
            task    => 'NetInventory',
            options => {
                DEVICE => [
                    {
                        IP           => '192.168.0.151',
                        ID           => '72',
                        TYPE         => 'PRINTER',
                        MODELSNMP_ID => '196',
                        AUTHSNMP_ID  => '1'
                    }
                ],
                AUTHENTICATION => [
                    {
                        ID             => '1',
                        PRIVPASSPHRASE => '',
                        PRIVPROTOCOL   => '',
                        AUTHPROTOCOL   => '',
                        AUTHPASSPHRASE => '',
                        COMMUNITY      => 'public',
                        VERSION        => '1',
                        USERNAME       => ''
                    }
                ],
                MODEL => [
                    {
                        ID   => '196',
                        NAME => '4675719',
                        WALK => [
                            {
                                OID    => '.1.3.6.1.2.1.2.2.1.1',
                                OBJECT => 'ifIndex',
                                LINK   => 'ifIndex',
                                VLAN   => '0'
                            },
                            {
                                LINK   => 'ifaddr',
                                VLAN   => '0',
                                OBJECT => 'ifaddr',
                                OID    => '.1.3.6.1.2.1.4.20.1.2'
                            }
                        ],
                        GET => [
                            {
                                OID    => '.1.3.6.1.2.1.1.5.0',
                                OBJECT => 'name',
                                LINK   => 'name',
                                VLAN   => '0'
                            },
                            {
                                VLAN   => '0',
                                LINK   => 'informations',
                                OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                                OBJECT => 'informations'
                            }
                        ],
                    }
                ],
                PARAM => [
                    {
                        CORE_QUERY    => '1',
                        PID           => '1280265498/024',
                        THREADS_QUERY => '4'
                    }
                ],
            }
        },
    ],
    netinventory2 => [
        {
            task    => 'NetInventory',
            options => {
                DEVICE => [
                    {
                        IP           => '192.168.0.151',
                        ID           => '72',
                        TYPE         => 'PRINTER',
                        AUTHSNMP_ID  => '1',
                        MODELSNMP_ID => '196'
                    }
                ],
                AUTHENTICATION => [
                    {
                        COMMUNITY      => 'public',
                        PRIVPASSPHRASE => '',
                        VERSION        => '1',
                        USERNAME       => '',
                        AUTHPROTOCOL   => '',
                        ID             => '1',
                        PRIVPROTOCOL   => '',
                        AUTHPASSPHRASE => ''
                    }
                ],
                MODEL => [
                    {
                        ID   => '196',
                        NAME => '4675719',
                        WALK => [
                            {
                                VLAN   => '0',
                                OID    => '.1.3.6.1.2.1.2.2.1.1',
                                LINK   => 'ifIndex',
                                OBJECT => 'ifIndex'
                            },
                            {
                                OBJECT => 'ifaddr',
                                LINK   => 'ifaddr',
                                OID    => '.1.3.6.1.2.1.4.20.1.2',
                                VLAN   => '0'
                            }
                        ],
                        GET  => [
                            {
                                OBJECT => 'name',
                                LINK   => 'name',
                                VLAN   => '0',
                                OID    => '.1.3.6.1.2.1.1.5.0'
                            },
                            {
                                OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                                VLAN   => '0',
                                LINK   => 'informations',
                                OBJECT => 'informations'
                            }
                        ],
                    },
                    {
                        ID   => '197',
                        NAME => '4675720',
                        WALK => [
                            {
                                OBJECT => 'ifIndex',
                                LINK   => 'ifIndex',
                                OID    => '.1.3.6.1.2.1.2.2.1.1',
                                VLAN   => '0'
                            },
                            {
                                OBJECT => 'ifaddr',
                                VLAN   => '0',
                                OID    => '.1.3.6.1.2.1.4.20.1.2',
                                LINK   => 'ifaddr'
                            }
                        ],
                        GET => [
                            {
                                VLAN   => '0',
                                OID    => '.1.3.6.1.2.1.1.5.0',
                                LINK   => 'name',
                                OBJECT => 'name'
                            },
                            {
                                OBJECT => 'informations',
                                OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                                VLAN   => '0',
                                LINK   => 'informations'
                            }
                        ]
                    }
                ],
                PARAM => [
                    {
                        CORE_QUERY    => '1',
                        THREADS_QUERY => '4',
                        PID           => '1280265498/024'
                    }
                ],
            }
        }
    ],
    netinventory3 => [
        {
            task    => 'NetInventory',
            options => {
                DEVICE => [
                    {
                        ID           => '72',
                        IP           => '192.168.0.151',
                        MODELSNMP_ID => '196',
                        TYPE         => 'PRINTER',
                        AUTHSNMP_ID  => '1'
                    }
                ],
                AUTHENTICATION => [
                    {
                        ID             => '1',
                        AUTHPROTOCOL   => '',
                        PRIVPROTOCOL   => '',
                        USERNAME       => '',
                        AUTHPASSPHRASE => '',
                        VERSION        => '1',
                        COMMUNITY      => 'public',
                        PRIVPASSPHRASE => ''
                    },
                ],
                MODEL => [
                    {
                    ID   => '196',
                    NAME => '4675719',
                    WALK => [
                        {
                            VLAN   => '0',
                            LINK   => 'ifIndex',
                            OBJECT => 'ifIndex',
                            OID    => '.1.3.6.1.2.1.2.2.1.1'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'ifName',
                            OBJECT => 'ifName',
                            OID    => '.1.3.6.1.2.1.2.2.1.2'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'ifType',
                            OBJECT => 'ifType',
                            OID    => '.1.3.6.1.2.1.2.2.1.3'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'ifPhysAddress',
                            OBJECT => 'ifPhysAddress',
                            OID    => '.1.3.6.1.2.1.2.2.1.6'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'ifaddr',
                            OBJECT => 'ifaddr',
                            OID    => '.1.3.6.1.2.1.4.20.1.2'
                        }
                    ],
                    GET => [
                        {
                            VLAN   => '0',
                            LINK   => 'comments',
                            OBJECT => 'comments',
                            OID    => '.1.3.6.1.2.1.1.1.0'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'name',
                            OBJECT => 'name',
                            OID    => '.1.3.6.1.2.1.1.5.0'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'location',
                            OBJECT => 'location',
                            OID    => '.1.3.6.1.2.1.1.6.0'
                        },
                        {
                            VLAN   => '0',
                            LINK   => 'informations',
                            OBJECT => 'informations',
                            OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0'
                        }
                    ]
                    }
                ],
                PARAM => [
                    {
                        PID           => '1280265498/024',
                        THREADS_QUERY => '4',
                        CORE_QUERY    => '1'
                    }
                ]
            }
        },
    ],
    registry => [
        {
            task => 'Inventory',
        },
    ],
    wakeonlan => [
        {
            task => 'Inventory',
        },
        {
            task    => 'WakeOnLan',
            options => {
                PARAM => [
                    {
                        MAC => '00:1e:c2:0c:36:27'
                    },
                    {
                        MAC => '00:1e:c2:a7:26:6f'
                    },
                    {
                        MAC => '00:1e:52:ff:fe:67'
                    },
                    {
                        MAC => '00:00:39:23:0c:e1'
                    },
                    {
                        MAC => '00:00:39:23:0c:e1'
                    },
                    {
                        MAC => 'f6:68:20:52:41:53'
                    },
                    {
                        MAC => '52:08:19:1f:b6:f6'
                    }
                ],
            }
        },
    ],
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/messages/$test.xml";
    my $string = getAllLines(file => $file);
    my $message = FusionInventory::Agent::Message::Inbound->new(
        content => $string
    );

    my @tasks = $message->getTasks();
    cmp_deeply(\@tasks, $tests{$test}, $test);
}
