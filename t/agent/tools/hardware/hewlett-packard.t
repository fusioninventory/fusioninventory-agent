#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'hewlett-packard/unknown.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => '2C:76:8A:41:9F:6E'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => '2C:76:8A:41:9F:6E'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef
            },
        }
    ],
    'hewlett-packard/Inkjet_2800.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Business Inkjet 2800',
            SNMPHOSTNAME => 'HPIJ2800-02',
            MAC          => '00:11:0A:F5:CC:DC',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Business Inkjet 2800',
            SNMPHOSTNAME => 'HPIJ2800-02',
            MAC          => '00:11:0A:F5:CC:DC',
            MODELSNMP    => 'Printer0248',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13,CIDATE 08/11/2005',
                MEMORY       => 96,
                ID           => undef,
                NAME         => 'HPIJ2800-02',
                MODEL        => 'HP Business Inkjet 2800'
            },
            CARTRIDGES => {
                CARTRIDGEMAGENTA => 29,
                CARTRIDGEBLACK   => 12,
                CARTRIDGECYAN    => 32,
                CARTRIDGEYELLOW  => 33
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IP       => '10.104.102.194',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        MAC      => '00:11:0A:F5:CC:DC',
                        IFTYPE   => '6'
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        IFTYPE   => '24'
                    }
                ]
            },
        }
    ],
    'hewlett-packard/Inkjet_2800.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Business Inkjet 2800',
            SNMPHOSTNAME => 'HPIJ2800-01',
            MAC          => '00:11:0A:F5:1A:CC',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Business Inkjet 2800',
            SNMPHOSTNAME => 'HPIJ2800-01',
            MAC          => '00:11:0A:F5:1A:CC',
            MODELSNMP    => 'Printer0248',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13,CIDATE 08/11/2005',
                MODEL        => 'HP Business Inkjet 2800',
                MEMORY       => 96,
                ID           => undef,
                NAME         => 'HPIJ2800-01',
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '10.104.109.230',
                        IFTYPE   => '6',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        MAC      => '00:11:0A:F5:1A:CC',
                        IFNUMBER => '1'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        IFNUMBER => '2',
                        IFTYPE   => '24'
                    }
                ]
            },
            CARTRIDGES => {
                CARTRIDGEMAGENTA => 32,
                CARTRIDGEBLACK   => 10,
                CARTRIDGEYELLOW  => 27,
                CARTRIDGECYAN    => 32
            }
        }
    ],
    'hewlett-packard/OfficeJet_Pro_K5400.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Officejet Pro K5400',
            SNMPHOSTNAME => 'HP560332',
            MAC          => '00:21:5A:56:03:32',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Officejet Pro K5400',
            SNMPHOSTNAME => 'HP560332',
            MAC          => '00:21:5A:56:03:32',
            MODELSNMP    => 'Printer0285',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                NAME         => 'HP560332',
                ID           => undef,
                MODEL        => undef,
            },
            CARTRIDGES => {
                CARTRIDGEYELLOW  => 6,
                CARTRIDGECYAN    => 290,
                CARTRIDGEMAGENTA => 20,
                CARTRIDGEBLACK   => 9
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Eth0',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:56:03:32'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/OfficeJet_Pro_8600.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Officejet Pro 8600 N911g',
            SNMPHOSTNAME => 'HP8C0C51',
            MAC          => 'EC:9A:74:8C:0C:51',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Officejet Pro 8600 N911g',
            SNMPHOSTNAME => 'HP8C0C51',
            MAC          => 'EC:9A:74:8C:0C:51',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef
            },
        }
    ],
    'hewlett-packard/LaserJet_100_colorMFP_M175nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => 'B4:B5:2F:F6:FA:4A'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => 'B4:B5:2F:F6:FA:4A',
            MODELSNMP    => 'Printer0718',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NPIF6FA4A',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet 100 colorMFP M175nw',
                ID           => undef,
                NAME         => 'NPIF6FA4A',
                MODEL        => 'HP LaserJet 100 colorMFP M175nw',
                SERIAL       => 'NPIF6FA4A',
            },
            CARTRIDGES => {
                TONERBLACK   => 31,
                TONERYELLOW  => 82,
                TONERMAGENTA => 82,
                DRUMBLACK    => 96,
                TONERCYAN    => 83
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => 'B4:B5:2F:F6:FA:4A'
                    },
                    {
                        IFNAME   => 'wifi0',
                        IFNUMBER => '3',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => 'B4:B5:2F:F6:FA:4A'
                    },
                    {
                        IFNAME   => 'wifiUAP',
                        IFNUMBER => '4',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    }
                ]
            },
            PAGECOUNTERS => {
                TOTAL      => '367',
            }
        }
    ],
    'hewlett-packard/LaserJet_400_color_M451dn.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => 'B4:B5:2F:F6:74:98',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => 'B4:B5:2F:F6:74:98',
            MODELSNMP    => 'Printer0730',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCF300725',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet 400 color M451dn',
                NAME         => 'NPIF67498',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet 400 color M451dn',
                SERIAL       => 'CNCF300725'
            },
            PAGECOUNTERS => {
                COLOR      => '507',
                RECTOVERSO => '0',
                PRINTTOTAL => '541',
            },
            CARTRIDGES => {
                TONERMAGENTA => 73,
                TONERCYAN => 68,
                TONERBLACK => 53
            },
        }
    ],
    'hewlett-packard/LaserJet_500.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => '2C:76:8A:41:9F:6E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => '2C:76:8A:41:9F:6E',
            MODELSNMP    => 'Printer0628',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'SE00V4T'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
                NAME         => 'NPI419F6E',
                MODEL        => 'HP LaserJet 500 color M551',
                SERIAL       => 'SE00V4T',
                ID           => undef,
            },
            PAGECOUNTERS => {
                BLACK      => '1685',
                COLOR      => '6601',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '2C:76:8A:41:9F:6E'
                    }

                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_600.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => 'E8:39:35:90:92:1F',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => 'E8:39:35:90:92:1F',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_600.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => 'E8:39:35:90:22:AC'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => 'E8:39:35:90:22:AC'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_1300n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => '00:0E:7F:33:34:BA',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => '00:0E:7F:33:34:BA',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_1320.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => '00:14:38:61:04:4B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => '00:14:38:61:04:4B',
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW59NG6N',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                OTHERSERIAL  => '0x0115',
                SERIAL       => 'CNHW59NG6N',
                MODEL        => 'hp LaserJet 1320 series',
                ID           => undef,
                NAME         => 'NPI61044B',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:14:38:61:04:4B'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            },
            CARTRIDGES => {
                CARTRIDGEBLACK => 0,
                TONERBLACK     => 0
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1935',
                TOTAL      => '33545',
            }
        }
    ],
    'hewlett-packard/LaserJet_1320.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => '00:14:38:9A:3F:C7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => '00:14:38:9A:3F:C7',
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW625K6Z',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                SERIAL       => 'CNHW625K6Z',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPI9A3FC7',
                ID           => undef,
                MODEL        => 'hp LaserJet 1320 series'
            },
            CARTRIDGES => {
                CARTRIDGEBLACK => 92,
                TONERBLACK     => 92
            },
            PAGECOUNTERS => {
                RECTOVERSO => '2685',
                TOTAL      => '45790',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:14:38:9A:3F:C7'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_1320.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => '00:11:85:C6:8F:5E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => '00:11:85:C6:8F:5E',
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW49FHC4',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                SERIAL       => 'CNBW49FHC4',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPIC68F5E',
                ID           => undef,
                MODEL        => 'hp LaserJet 1320 series'
            },
            PAGECOUNTERS => {
                TOTAL      => '5868',
                RECTOVERSO => '258',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:11:85:C6:8F:5E'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 34,
                CARTRIDGEBLACK => 34
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:8A:6E:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:8A:6E:5B',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:8A:6E:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:8A:6E:5B',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:0D:AA:C6',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:0D:AA:C6',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:10:83:54:D6:08',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:10:83:54:D6:08',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => 'l1618a',
            MAC          => '00:0E:7F:EA:E1:B7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => 'l1618a',
            MAC          => '00:0E:7F:EA:E1:B7',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2100.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:C3:BE:CF',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            MAC          => '00:30:C1:C3:BE:CF',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/LaserJet_2200.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2200',
            MAC          => '00:30:C1:01:1E:68',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 2200',
            MAC          => '00:30:C1:01:1E:68',
            MODELSNMP    => 'Printer0391',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FRFRH43314',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet 2200',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.07.19,JETDIRECT,JD33,EEPROM G.08.49',
                MEMORY       => '16',
                SERIAL       => 'FRFRH43314',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '100',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '12873',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.07.19,JETDIRECT,JD33,EEPROM G.08.49',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.20',
                        MAC      => '00:30:C1:01:1E:68',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_2300.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 2300 series',
            SNMPHOSTNAME => 'NPIA1D034',
            MAC          => '00:01:E6:A1:D0:34',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 2300 series',
            SNMPHOSTNAME => 'NPIA1D034',
            MAC          => '00:01:E6:A1:D0:34',
            MODELSNMP    => 'Printer0385',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCDF57941',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 2300 series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.24.08,CIDATE 02/26/2003',
                NAME         => 'NPIA1D034',
                MEMORY       => '48',
                SERIAL       => 'CNCDF57941',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '94',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '2066',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.24.08',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.126',
                        MAC      => '00:01:E6:A1:D0:34',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.24.08',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_2300.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 2300 series',
            MAC          => '00:30:C1:60:C8:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 2300 series',
            MAC          => '00:30:C1:60:C8:5B',
            MODELSNMP    => 'Printer0385',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCHM24955',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 2300 series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.07.02,JETDIRECT,JD30,EEPROM G.08.40',
                MEMORY       => '48',
                SERIAL       => 'CNCHM24955',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '1',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '219',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.07.02,JETDIRECT,JD30,EEPROM G.08.40',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.66',
                        MAC      => '00:30:C1:60:C8:5B',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_2600n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => '00:1A:4B:18:64:A0',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => '00:1A:4B:18:64:A0',
            MODELSNMP    => 'Printer0093',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                NAME         => 'NPI1864A0',
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'NetDrvr',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1A:4B:18:64:A0'
                    }

                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_3600.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => '00:1B:78:6F:72:C5',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => '00:1B:78:6F:72:C5',
            MODELSNMP    => 'Printer0390',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNXJD65169',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD121,EEPROM V.30.31,CIDATE 06/17/2005',
                NAME         => 'NPI6F72C5',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP Color LaserJet 3600',
                ID           => undef,
                SERIAL       => 'CNXJD65169',
            },
            PAGECOUNTERS => {
                COLOR      => '9946',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD121,EEPROM V.30.31',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1B:78:6F:72:C5'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD121,EEPROM V.30.31',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            },
            CARTRIDGES => {
                TONERMAGENTA => 46,
                TONERYELLOW  => 45,
                TONERBLACK   => 63,
                TONERCYAN    => 44
            }
        }
    ],
    'hewlett-packard/LaserJet_4000.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => '00:60:B0:91:3D:9D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => '00:60:B0:91:3D:9D',
            MODELSNMP    => 'Printer0391',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NLEW064384',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.05.35,JETDIRECT,JD30,EEPROM G.05.35',
                LOCATION     => 'lwcompta',
                SERIAL       => 'NLEW064384',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet 4000 Series',
                ID           => undef,
                NAME         => 'inspiron8',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.05.35,JETDIRECT,JD30,EEPROM G.05.35',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:60:B0:91:3D:9D'
                    }

                ]
            },
            PAGECOUNTERS => {
                RECTOVERSO => '152',
            },
            CARTRIDGES => {
                TONERBLACK => 100
            }
        }
    ],
    'hewlett-packard/LaserJet_4050.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => '00:30:C1:8C:D5:6C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => '00:30:C1:8C:D5:6C',
            MODELSNMP    => 'Printer0615',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NL7N093250'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet 4050 Series ',
                SERIAL       => 'NL7N093250',
                OTHERSERIAL  => '0x011520',
                NAME         => 'imprimanteBR',
                MODEL        => 'HP LaserJet 4050 Series ',
                ID           => undef,
                LOCATION     => 'impbe93'
            },
            PAGECOUNTERS => {
                TOTAL      => '252311',
                RECTOVERSO => '0',
            },
            CARTRIDGES => {
                CARTRIDGEBLACK => 0,
                TONERBLACK     => 0
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.08.08,JETDIRECT,JD33,EEPROM G.08.04',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:30:C1:8C:D5:6C'
                    }
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4050.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            MAC          => '00:10:83:BA:17:CE',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            MAC          => '00:10:83:BA:17:CE',
            MODELSNMP    => 'Printer0615',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NL7V061384',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet 4050 Series ',
                COMMENTS     => 'HP LaserJet 4050 Series ',
                MEMORY       => '16',
                SERIAL       => 'NL7V061384',
                OTHERSERIAL  => '0x011520',
            },
            CARTRIDGES => {
                CARTRIDGEBLACK   => '0',
                TONERBLACK       => '0',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '57131',
                TOTAL      => '243041',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.07.19,JETDIRECT,JD33,EEPROM G.08.40',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:10:83:BA:17:CE',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4200.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => '00:01:E6:A1:A7:81',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => '00:01:E6:A1:A7:81',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFX305387'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.25.09,CIDATE 07/24/2003',
                SERIAL       => 'CNFX305387',
                OTHERSERIAL  => '0x0115',
                NAME         => 'IMP41200n0',
                ID           => undef,
                MODEL        => 'hp LaserJet 4200'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.25.09',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:01:E6:A1:A7:81'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.25.09',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            },
            PAGECOUNTERS => {
                RECTOVERSO => '0',
            },
            CARTRIDGES => {
                TONERBLACK     => 95,
                MAINTENANCEKIT => 71
            }
        }
    ],
    'hewlett-packard/LaserJet_4250.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => '00:11:85:D9:F6:C7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => '00:11:85:D9:F6:C7',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCXG01622'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.43,CIDATE 06/23/2004',
                NAME         => 'impKirat',
                SERIAL       => 'CNCXG01622',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'hp LaserJet 4250'
            },
            CARTRIDGES => {
                TONERBLACK     => 52,
                MAINTENANCEKIT => 56
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.43',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:11:85:D9:F6:C7'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.43',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_4250.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l0812a',
            MAC          => '00:14:38:DF:A5:30',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l0812a',
            MAC          => '00:14:38:DF:A5:30',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXH84872',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59,CIDATE 05/10/2005',
                NAME         => 'l0812a',
                MEMORY       => '256',
                SERIAL       => 'CNHXH84872',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '86',
                MAINTENANCEKIT  => '73',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.88',
                        MAC      => '00:14:38:DF:A5:30',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA2B02',
            MAC          => '00:23:7D:7E:A1:31',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA2B02',
            MAC          => '00:23:7D:7E:A1:31',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXG83836',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63,CIDATE 04/07/2006',
                NAME         => 'NPIEA2B02',
                MEMORY       => '208',
                SERIAL       => 'CNHXG83836',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '61',
                MAINTENANCEKIT  => '25',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.8.82',
                        MAC      => '00:23:7D:7E:A1:31',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA3BFC',
            MAC          => '00:14:38:EA:3B:FC',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA3BFC',
            MAC          => '00:14:38:EA:3B:FC',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXB71032',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59,CIDATE 05/10/2005',
                NAME         => 'NPIEA3BFC',
                MEMORY       => '208',
                SERIAL       => 'CNHXB71032',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '25',
                MAINTENANCEKIT  => '41',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.90',
                        MAC      => '00:14:38:EA:3B:FC',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l1310a',
            MAC          => '00:14:38:EA:2B:C4',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l1310a',
            MAC          => '00:14:38:EA:2B:C4',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXC68053',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59,CIDATE 05/10/2005',
                NAME         => 'l1310a',
                MEMORY       => '208',
                SERIAL       => 'CNHXC68053',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '23',
                MAINTENANCEKIT  => '55',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.13.25',
                        MAC      => '00:14:38:EA:2B:C4',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l1439a',
            MAC          => '00:14:38:E2:12:D8',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l1439a',
            MAC          => '00:14:38:E2:12:D8',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXH84870',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59,CIDATE 05/10/2005',
                NAME         => 'l1439a',
                MEMORY       => '208',
                SERIAL       => 'CNHXH84870',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '84',
                MAINTENANCEKIT  => '87',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.59',
                        MAC      => '00:14:38:E2:12:D8',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l2007a',
            MAC          => '00:1B:78:28:26:CB',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'l2007a',
            MAC          => '00:1B:78:28:26:CB',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXB68748',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63,CIDATE 04/07/2006',
                NAME         => 'l2007a',
                MEMORY       => '208',
                SERIAL       => 'CNHXB68748',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '58',
                MAINTENANCEKIT  => '57',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.41',
                        MAC      => '00:1B:78:28:26:CB'
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.63',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEAFA59',
            MAC          => '00:14:38:EA:FA:59',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEAFA59',
            MAC          => '00:14:38:EA:FA:59',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXB71050',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59,CIDATE 05/10/2005',
                NAME         => 'NPIEAFA59',
                MEMORY       => '208',
                SERIAL       => 'CNHXB71050',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '5',
                MAINTENANCEKIT  => '53',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.123',
                        MAC      => '00:14:38:EA:FA:59',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.59',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_4250.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA8E82',
            MAC          => '00:23:7D:81:22:F7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'NPIEA8E82',
            MAC          => '00:23:7D:81:22:F7',
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHXJ45092',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'hp LaserJet 4250',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.33.19,CIDATE 12/17/2008',
                NAME         => 'NPIEA8E82',
                MEMORY       => '208',
                SERIAL       => 'CNHXJ45092',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '83',
                MAINTENANCEKIT  => '81',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.33.19',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.33.19',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.10.59',
                        MAC      => '00:23:7D:81:22:F7',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_5550.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => '00:1B:78:F0:F4:47',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => '00:1B:78:F0:F4:47',
            MODELSNMP    => 'Printer0614',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'SG96304AD8'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'hp color LaserJet 5550 ',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                SERIAL       => 'SG96304AD8',
                MODEL        => 'hp color LaserJet 5550 ',
                NAME         => 'IDD116',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1B:78:F0:F4:47'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13',
                        IFNUMBER => '2',
                        IFTYPE   => 'softwareLoopback(24)'
                    }
                ]
            },
            CARTRIDGES => {
                TONERYELLOW  => 96,
                TONERCYAN    => 95,
                TONERBLACK   => 12,
                TONERMAGENTA => 95
            },
            PAGECOUNTERS => {
                RECTOVERSO => '0',
                BLACK      => '102279',
                COLOR      => '92447'
            }
        }
    ],
    'hewlett-packard/LaserJet_CM1312nfi_MFP.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => '00:1F:29:27:1E:90',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => '00:1F:29:27:1E:90',
            MODELSNMP    => 'Printer0396',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNB885QNXP'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNB885QNXP,FN:NL106CH,SVCID:18334,PID:HP Color LaserJet CM1312nfi MFP',
                NAME         => 'NPI271E90',
                LOCATION     => 'HP Color LaserJet CM1312nfi MFP',
                MODEL        => 'HP Color LaserJet CM1312nfi MFP',
                OTHERSERIAL  => '0x0115',
                SERIAL       => 'CNB885QNXP',
                ID           => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1F:29:27:1E:90'
                    }
                ]
            },
            CARTRIDGES => {
                TONERCYAN    => 35,
                TONERBLACK   => 68,
                TONERMAGENTA => 89,
                TONERYELLOW  => 59
            }
        }
    ],
    'hewlett-packard/LaserJet_CM1415fn.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => '68:B5:99:AD:61:8E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => '68:B5:99:AD:61:8E',
            MODELSNMP    => 'Printer0575',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNF8BC11FK,FN:QD30T49,SVCID:21055,PID:HP LaserJet CM1415fn',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'HP LaserJet CM1415fn',
                NAME         => 'B536-lwc237-Fax',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '68:B5:99:AD:61:8E'
                    }
                ]
            },
            CARTRIDGES => {
                TONERCYAN    => 35,
                TONERMAGENTA => 31,
                TONERYELLOW  => 33,
                TONERBLACK   => 25
            },
            PAGECOUNTERS => {
                BLACK      => '760',
                COLOR      => '4720',
                RECTOVERSO => '0'
            }
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => '00:23:7D:7F:5D:71',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => '00:23:7D:7F:5D:71',
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFN9BYG41'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                LOCATION     => 'HP Color LaserJet CM2320fxi MFP',
                SERIAL       => 'CNFN9BYG41',
                NAME         => 'NPI7F5D71',
                MODEL        => 'HP Color LaserJet CM2320fxi MFP',
                OTHERSERIAL  => '0x0115',
                ID           => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:23:7D:7F:5D:71'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK   => 43,
                TONERMAGENTA => 41,
                TONERYELLOW  => 18,
                TONERCYAN    => 46
            },
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => '00:23:7D:7F:5D:71',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => '00:23:7D:7F:5D:71',
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFN9BYG41'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                SERIAL       => 'CNFN9BYG41',
                LOCATION     => 'HP Color LaserJet CM2320fxi MFP',
                NAME         => 'NPI7F5D71',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'HP Color LaserJet CM2320fxi MFP'
            },
            CARTRIDGES => {
                TONERBLACK   => 46,
                TONERMAGENTA => 46,
                TONERYELLOW  => 15,
                TONERCYAN    => 52
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:23:7D:7F:5D:71'
                   }
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => '00:23:7D:82:88:33',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => '00:23:7D:82:88:33',
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNDN99YG0D'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                SERIAL       => 'CNDN99YG0D',
                LOCATION     => 'HP Color LaserJet CM2320fxi MFP',
                NAME         => 'NPI828833',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'HP Color LaserJet CM2320fxi MFP'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:23:7D:82:88:33'
                    }
                ]
            },
            CARTRIDGES => {
                TONERMAGENTA => 87,
                TONERBLACK   => 31,
                TONERCYAN    => 96,
                TONERYELLOW  => 17
            },
        }
    ],
    'hewlett-packard/LaserJet_CM2320nf_MFP.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => '3C:4A:92:B3:02:A7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => '3C:4A:92:B3:02:A7',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFTBDZ0FN',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNFTBDZ0FN,FN:PT60J59,SVCID:21046,PID:HP Color LaserJet CM2320nf MFP',
                MODEL        => 'HP Color LaserJet CM2320nf MFP',
                SERIAL       => 'CNFTBDZ0FN',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPIB302A7',
                ID           => undef,
                LOCATION     => 'HP Color LaserJet CM2320nf MFP'
            },
            PAGECOUNTERS => {
                COLOR      => '789',
                BLACK      => '141',
                RECTOVERSO => '0',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '3C:4A:92:B3:02:A7'
                    }
                ]
            },
            CARTRIDGES => {
                TONERYELLOW  => 56,
                TONERMAGENTA => 55,
                TONERBLACK   => 23,
                TONERCYAN    => 50
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025dn.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => '00:1F:29:2A:D7:43',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => '00:1F:29:2A:D7:43',
            MODELSNMP    => 'Printer0414',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCSF01053',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCSF01053,FN:MB01ZGH,SVCID:18347,PID:HP Color LaserJet CP2025dn',
                OTHERSERIAL  => '0x0115',
                LOCATION     => 'HP Color LaserJet CP2025dn',
                NAME         => 'NPI2AD743',
                ID           => undef,
                SERIAL       => 'CNCSF01053',
                MODEL        => 'HP Color LaserJet CP2025dn'
            },
            PAGECOUNTERS => {
                RECTOVERSO => '2584',
                BLACK      => '9817',
                COLOR      => '21930'
            },
            CARTRIDGES => {
                TONERYELLOW  => 34,
                TONERCYAN    => 34,
                TONERMAGENTA => 18,
                TONERBLACK   => 19
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1F:29:2A:D7:43'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => 'B4:99:BA:C3:D5:FF'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => 'B4:99:BA:C3:D5:FF',
            MODELSNMP    => 'Printer0414',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHS437790',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNHS437790,FN:MB27295,SVCID:22039,PID:HP Color LaserJet CP2025dn',
                MODEL        => 'HP Color LaserJet CP2025dn',
                ID           => undef,
                SERIAL       => 'CNHS437790',
                NAME         => 'NPIC3D5FF',
                OTHERSERIAL  => '0x0115',
                LOCATION     => 'HP Color LaserJet CP2025dn'
            },
            PAGECOUNTERS => {
                BLACK      => '1198',
                RECTOVERSO => '1',
                COLOR      => '7501',
            },
            CARTRIDGES => {
                TONERYELLOW => 24,
                TONERMAGENTA => 33,
                TONERCYAN => 48,
                TONERBLACK => 89
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => 'B4:99:BA:C3:D5:FF'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => '2C:27:D7:11:70:08',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => '2C:27:D7:11:70:08',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHSP65440',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNHSP65440,FN:MB303HX,SVCID:21236,PID:HP Color LaserJet CP2025n',
                NAME         => 'NPI117008',
                MODEL        => 'HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNHSP65440'
            },
            CARTRIDGES => {
                TONERYELLOW  => 87,
                TONERCYAN    => 72,
                TONERMAGENTA => 85,
                TONERBLACK   => 41
            },
            PAGECOUNTERS => {
                COLOR      => '2309',
                BLACK      => '1145',
                RECTOVERSO => '0',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '2C:27:D7:11:70:08'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => '00:21:5A:84:C4:81',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => '00:21:5A:84:C4:81',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS404796',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS404796,FN:MB04VB0,SVCID:19316,PID:HP Color LaserJet CP2025n',
                ID           => undef,
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNCS404796',
                NAME         => 'NPI84C481',
                MODEL        => 'HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK   => 31,
                TONERMAGENTA => 32,
                TONERCYAN    => 69,
                TONERYELLOW  => 77
            },
            PAGECOUNTERS => {
                BLACK      => '3459',
                COLOR      => '11263',
                RECTOVERSO => '0',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:84:C4:81'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => '00:21:5A:84:C4:81',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => '00:21:5A:84:C4:81',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS404796',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS404796,FN:MB04VB0,SVCID:19316,PID:HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPI84C481',
                MODEL        => 'HP Color LaserJet CP2025n',
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNCS404796',
                ID           => undef
            },
            PAGECOUNTERS => {
                RECTOVERSO => '0',
                BLACK      => '3896',
                COLOR      => '12731',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:84:C4:81'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK   => 83,
                TONERMAGENTA => 93,
                TONERCYAN    => 33,
                TONERYELLOW  => 50
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => '00:21:5A:81:E3:A7'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => '00:21:5A:81:E3:A7',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS212370',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS212370,FN:MB03SY2,SVCID:19127,PID:HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP Color LaserJet CP2025n',
                NAME         => 'NPI81E3A7',
                SERIAL       => 'CNCS212370',
                LOCATION     => 'HP Color LaserJet CP2025n',
                ID           => undef
            },
            CARTRIDGES => {
                TONERBLACK   => 41,
                TONERMAGENTA => 47,
                TONERYELLOW  => 63,
                TONERCYAN    => 93
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:81:E3:A7'
                    }
                ]
            },
            PAGECOUNTERS => {
                COLOR      => '16450',
                BLACK      => '5506',
                RECTOVERSO => '0',
            },
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => '78:AC:C0:8F:A1:DD',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => '78:AC:C0:8F:A1:DD',
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHSN58554',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNHSN58554,FN:MB258FW,SVCID:21095,PID:HP Color LaserJet CP2025n',
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNHSN58554',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPI8FA1DD',
                MODEL        => 'HP Color LaserJet CP2025n'
            },
            PAGECOUNTERS => {
                COLOR      => '5758',
                BLACK      => '3843',
                RECTOVERSO => '0'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '78:AC:C0:8F:A1:DD'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK   => 55,
                TONERMAGENTA => 23,
                TONERYELLOW  => 29,
                TONERCYAN    => 18
            }
        }
    ],
    'hewlett-packard/LaserJet_P2015.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => '00:21:5A:83:EC:85',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => '00:21:5A:83:EC:85',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW898043',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW898043,FN:JK5FJN3,SVCID:18327,PID:HP LaserJet P2015 Series',
                SERIAL       => 'CNBW898043',
                ID           => undef,
                NAME         => 'NPI83EC85',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P2015 Series',
                LOCATION     => 'Boise, ID, USA'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:83:EC:85'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK => 44
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                RECTOVERSO => '0',
                BLACK      => '36596'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2015.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => '00:1B:78:13:EE:63'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => '00:1B:78:13:EE:63',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW7BQ7BS',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW7BQ7BS,FN:JK44SRD,SVCID:18021,PID:HP LaserJet P2015 Series',
                OTHERSERIAL  => '0x0115',
                LOCATION     => 'Boise, ID, USA',
                MODEL        => 'HP LaserJet P2015 Series',
                SERIAL       => 'CNBW7BQ7BS',
                NAME         => 'NPI13EE63',
                ID           => undef
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                RECTOVERSO => '0',
                BLACK      => '25333',
            },
            CARTRIDGES => {
                TONERBLACK => 59
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1B:78:13:EE:63'
                    }
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => '00:21:5A:83:EC:85',
            SNMPHOSTNAME => 'NPI83EC85',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => '00:21:5A:83:EC:85',
            SNMPHOSTNAME => 'NPI83EC85',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW898043',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW898043,FN:JK5FJN3,SVCID:18327,PID:HP LaserJet P2015 Series',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P2015 Series',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW898043',
                ID           => undef,
                NAME         => 'NPI83EC85',
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                RECTOVERSO => '0',
                BLACK      => '36301',
            },
            CARTRIDGES => {
                TONERBLACK => 50
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:83:EC:85'
                    }
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI2BAB3D',
            MAC          => '00:1F:29:2B:AB:3D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI2BAB3D',
            MAC          => '00:1F:29:2B:AB:3D',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW87R2XX',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW87R2XX,FN:JK5BJMX,SVCID:00000,PID:HP LaserJet P2015 Series',
                NAME         => 'NPI2BAB3D',
                MEMORY       => '95',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW87R2XX',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '65',
            },
            PAGECOUNTERS => {
                BLACK      => '129336',
                COLOR      => '0',
                RECTOVERSO => '0',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.213',
                        MAC      => '00:1F:29:2B:AB:3D',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8CA86F',
            MAC          => '00:17:08:8C:A8:6F',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8CA86F',
            MAC          => '00:17:08:8C:A8:6F',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW6DW3R8',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW6DW3R8,FN:JK151HQ,SVCID:00000,PID:l0713a',
                NAME         => 'NPI8CA86F',
                MEMORY       => '159',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW6DW3R8',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '18',
            },
            PAGECOUNTERS => {
                BLACK      => '45078',
                COLOR      => '0',
                RECTOVERSO => '20379',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.14',
                        MAC      => '00:17:08:8C:A8:6F',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8E6910',
            MAC          => '00:17:08:8E:69:10',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8E6910',
            MAC          => '00:17:08:8E:69:10',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW7171V8',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW7171V8,FN:JK15ESY,SVCID:00000,PID:HP LaserJet P2015 Series',
                NAME         => 'NPI8E6910',
                MEMORY       => '159',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW7171V8',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '46',
            },
            PAGECOUNTERS => {
                BLACK      => '16610',
                COLOR      => '0',
                RECTOVERSO => '423',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.22',
                        MAC      => '00:17:08:8E:69:10',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8C980D',
            MAC          => '00:17:08:8C:98:0D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI8C980D',
            MAC          => '00:17:08:8C:98:0D',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW6DW37G',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW6DW37G,FN:JK15170,SVCID:00000,PID:l2405a',
                NAME         => 'NPI8C980D',
                MEMORY       => '159',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW6DW37G',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '32',
            },
            PAGECOUNTERS => {
                BLACK      => '5943',
                COLOR      => '0',
                RECTOVERSO => '930',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.122',
                        MAC      => '00:17:08:8C:98:0D',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI7954CF',
            MAC          => '00:23:7D:79:54:CF',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI7954CF',
            MAC          => '00:23:7D:79:54:CF',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW76W0B8',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW76W0B8,FN:JK62250,SVCID:00000,PID:HP LaserJet P2015 Series',
                NAME         => 'NPI7954CF',
                MEMORY       => '95',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW76W0B8',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '66',
            },
            PAGECOUNTERS => {
                BLACK      => '96192',
                COLOR      => '0',
                RECTOVERSO => '620',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.220',
                        MAC      => '00:23:7D:79:54:CF',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI156F54',
            MAC          => '00:1A:4B:15:6F:54',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI156F54',
            MAC          => '00:1A:4B:15:6F:54',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW74K7GP',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW74K7GP,FN:JK306JC,SVCID:00000,PID:HP LaserJet P2015 Series',
                NAME         => 'NPI156F54',
                MEMORY       => '95',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW74K7GP',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '90',
            },
            PAGECOUNTERS => {
                BLACK      => '30412',
                COLOR      => '0',
                RECTOVERSO => '65',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.197',
                        MAC      => '00:1A:4B:15:6F:54',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015.10.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI166E31',
            MAC          => '00:1F:29:16:6E:31',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI166E31',
            MAC          => '00:1F:29:16:6E:31',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW84P402',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2015 Series',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW84P402,FN:JK54RBG,SVCID:00000,PID:HP LaserJet P2015 Series',
                NAME         => 'NPI166E31',
                MEMORY       => '95',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW84P402',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '33',
            },
            PAGECOUNTERS => {
                BLACK      => '8880',
                COLOR      => '0',
                RECTOVERSO => '2115',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'LOOPBACK',
                        IFTYPE   => 'softwareLoopback(24)',
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Ethernet',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.233',
                        MAC      => '00:1F:29:16:6E:31',
                    },
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet-P4014.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4014',
            SNMPHOSTNAME => 'NPIFFF0F2',
            MAC          => '18:A9:05:FF:F0:F2',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4014',
            SNMPHOSTNAME => 'NPIFFF0F2',
            MAC          => '18:A9:05:FF:F0:F2',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFX409800',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41,CIDATE 06/12/2009',
                NAME         => 'NPIFFF0F2',
                ID           => undef,
                MODEL        => 'HP LaserJet P4014',
                SERIAL       => 'CNFX409800',
                MEMORY       => 384
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41',
                        IFNUMBER => '1',
                        IFTYPE   => '24'
                    },
                    {
                        IFNUMBER => '2',
                        MAC      => '18:A9:05:FF:F0:F2',
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41',
                        IP       => '10.75.13.175',
                        IFTYPE   => '6'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 18,
                MAINTENANCEKIT => 32
            }
        }
    ],
    'hewlett-packard/ProCurve_J8697A_Switch_5406zl.walk' => [
        {
            MANUFACTURER => 'Hewlett Packard',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_',
            SNMPHOSTNAME => 'oyapock CR2',
            MAC          => '00:18:71:C1:E0:00',
        },
        {
            MANUFACTURER => 'Hewlett Packard',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_',
            SNMPHOSTNAME => 'oyapock CR2',
            MAC          => '00:18:71:C1:E0:00',
            MODELSNMP    => 'Networking2063',
            MODEL        => undef,
            SERIAL       => 'SG707SU03Y',
            FIRMWARE     => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett Packard',
                TYPE         => 'NETWORKING',
                COMMENTS     => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_',
                MODEL        => 'J8697A',
                UPTIME       => '(293555959) 33 days, 23:25:59.59',
                CONTACT      => 'systeme@ac-guyane.fr',
                LOCATION     => 'datacenter',
                MAC          => '00:18:71:C1:E0:00',
                SERIAL       => 'SG707SU03Y',
                FIRMWARE     => 'K.15.28 K.15.04.0015m',
                ID           => undef,
                NAME         => 'oyapock CR2',
                IPS          => {
                    IP => [
                        '127.0.0.1',
                        '172.27.192.226',
                        '172.27.192.33',
                        '172.27.193.125',
                        '172.27.205.253',
                        '172.31.192.244',
                        '172.31.193.246',
                        '172.31.196.253',
                        '172.31.201.253',
                        '172.31.203.253',
                        '172.31.204.125',
                        '172.31.204.253',
                        '172.31.205.125',
                        '172.31.205.253',
                        '192.168.227.246'
                    ]
                },
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER         => '1',
                        IFNAME           => 'A1',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(137791) 0:22:57.91',
                        MAC              => '00:18:71:C1:F0:FF',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFDESCR          => 'A1',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '2281257823',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '1349379502',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.196.140',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB010B00',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '141'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '2',
                        IFINOCTETS       => '1790849661',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '351638347',
                        MAC              => '00:18:71:C1:F0:FE',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(137791) 0:22:57.91',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'A2',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A2',
                        CONNECTIONS => {
                            CONNECTION => {
                                IP       => '172.31.196.140',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB010B00',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '143'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '3',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:FD',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(140056) 0:23:20.56',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'A3',
                        IFINOCTETS       => '2596611853',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '1368455180',
                        IFNAME           => 'A3',
                        IFOUTERRORS      => '0',
                        CONNECTIONS => {
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB0D8100',
                                IP       => '172.31.196.141'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '4',
                        IFOUTOCTETS      => '205027037',
                        IFINOCTETS       => '2096487256',
                        IFMTU            => '1500',
                        IFDESCR          => 'A4',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(140106) 0:23:21.06',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:FC',
                        IFINERRORS       => '0',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A4',
                        CONNECTIONS => {
                            CONNECTION => {
                                SYSNAME  => '0x0019BB0D8100',
                                IFDESCR  => '143',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.141'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '5',
                        IFOUTOCTETS      => '2189748070',
                        IFINOCTETS       => '2759835685',
                        IFMTU            => '1500',
                        IFDESCR          => 'A5',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(98419) 0:16:24.19',
                        MAC              => '00:18:71:C1:F0:FB',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A5',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0016B9138000',
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.142'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '6',
                        IFNAME           => 'A6',
                        IFOUTERRORS      => '0',
                        MAC              => '00:18:71:C1:F0:FA',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(98419) 0:16:24.19',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'A6',
                        IFINOCTETS       => '710340837',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '1497261298',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                SYSNAME  => '0x0016B9138000',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '143',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.142'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '7',
                        IFNAME           => 'A7',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(133722) 0:22:17.22',
                        MAC              => '00:18:71:C1:F0:F9',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFDESCR          => 'A7',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '1500',
                        IFINOCTETS       => '264235442',
                        IFOUTOCTETS      => '1045414825',
                        CONNECTIONS => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.196.143',
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0016B9142B00',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            }
                        },
                    },
                    {
                        IFNUMBER         => '8',
                        IFNAME           => 'A8',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'A8',
                        MAC              => '00:18:71:C1:F0:F8',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(133722) 0:22:17.22',
                        IFOUTOCTETS      => '1496580095',
                        IFINOCTETS       => '2740877036',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0016B9142B00',
                                IFDESCR  => '143',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.143'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '9',
                        IFLASTCHANGE     => '(171654) 0:28:36.54',
                        IFSPEED          => '1000000000',
                        MAC              => '00:18:71:C1:F0:F7',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFDESCR          => 'A9',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '1383661651',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '1593815865',
                        IFNAME           => 'A9',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.196.150',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB1B4D00'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '10',
                        IFMTU            => '1500',
                        IFINOCTETS       => '2224332599',
                        IFOUTOCTETS      => '1552508202',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F6',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(171654) 0:28:36.54',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'A10',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A10',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.150',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '143',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB1B4D00'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '11',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F5',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFNAME           => 'A11',
                        IFOUTERRORS      => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME => 'DEFAULT_VLAN'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '12',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F4',
                        IFINERRORS       => '0',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A12',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '13',
                        IFNAME           => 'A13',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'A13',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(147598) 0:24:35.98',
                        IFSPEED          => '1000000000',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F3',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2302731832',
                        IFINOCTETS       => '3735158120',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.151',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB1ACC00',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '141'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '14',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F2',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFNAME           => 'A14',
                        IFOUTERRORS      => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME => 'DEFAULT_VLAN'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '15',
                        IFNAME           => 'A15',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'A15',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(154728) 0:25:47.28',
                        MAC              => '00:18:71:C1:F0:F1',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFOUTOCTETS      => '284146569',
                        IFINOCTETS       => '3361365604',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '118',
                                SYSNAME  => '0x0019BB01A600',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.160'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '16',
                        IFNAME           => 'A16',
                        IFOUTERRORS      => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:F0',
                        IFINERRORS       => '0',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '17',
                        IFOUTOCTETS      => '2435360597',
                        IFINOCTETS       => '348605692',
                        IFMTU            => '1500',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'A17',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:EF',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(152568) 0:25:25.68',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A17',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.161',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '118',
                                SYSNAME  => '0x0019BB058200',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '18',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        MAC              => '00:18:71:C1:F0:EE',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A18',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '19',
                        IFDESCR          => 'A19',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(143621) 0:23:56.21',
                        IFSPEED          => '1000000000',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:ED',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1786194494',
                        IFINOCTETS       => '28689859',
                        IFMTU            => '1500',
                        IFNAME           => 'A19',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                SYSNAME  => '0x0018FEF9A800',
                                IFDESCR  => '262',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.162'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '20',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        MAC              => '00:18:71:C1:F0:EC',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A20',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '21',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A21',
                        IFINOCTETS       => '2943397531',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '1009676074',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(94699) 0:15:46.99',
                        MAC              => '00:18:71:C1:F0:EB',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFDESCR          => 'A21',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.163',
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '262',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x001C2EE58B00'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '22',
                        IFNAME           => 'A22',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(57936) 0:09:39.36',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:EA',
                        IFINERRORS       => '0',
                        IFDESCR          => 'A22',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '3614341248',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '372261477',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '22',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB172200',
                                IP       => '172.31.192.245'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '23',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'A23',
                        IFOUTOCTETS      => '3322662505',
                        IFINOCTETS       => '1968825162',
                        IFMTU            => '1500',
                        IFDESCR          => 'A23',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFLASTCHANGE     => '(57936) 0:09:39.36',
                        IFSPEED          => '1000000000',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:E9',
                        IFTYPE           => '6',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB172200',
                                IFDESCR  => '23',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.192.245'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '24',
                        IFNAME           => 'A24',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'A24',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:E8',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(57936) 0:09:39.36',
                        IFOUTOCTETS      => '2284145698',
                        IFINOCTETS       => '3412112397',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.192.245',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB172200',
                                IFDESCR  => '24',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '25',
                        IFNAME           => 'B1',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'B1',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:E7',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(147667) 0:24:36.67',
                        IFOUTOCTETS      => '1169469549',
                        IFINOCTETS       => '1056898244',
                        IFMTU            => '1500',
                        CONNECTIONS => {
                            CONNECTION => {
                                IP       => '172.31.196.151',
                                IFDESCR  => '143',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB1ACC00',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '26',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'B2',
                        MAC              => '00:18:71:C1:F0:E6',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFLASTCHANGE     => '(147617) 0:24:36.17',
                        IFSPEED          => '1000000000',
                        IFOUTOCTETS      => '558861009',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3042721785',
                        IFNAME           => 'B2',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.151',
                                IFDESCR  => '118',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB1ACC00',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '27',
                        IFLASTCHANGE     => '(154748) 0:25:47.48',
                        IFSPEED          => '1000000000',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:E5',
                        IFTYPE           => '6',
                        IFDESCR          => 'B3',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '3237184662',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '146927983',
                        IFNAME           => 'B3',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB01A600',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.160'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '28',
                        IFLASTCHANGE     => '(154797) 0:25:47.97',
                        IFSPEED          => '1000000000',
                        MAC              => '00:18:71:C1:F0:E4',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFDESCR          => 'B4',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '1500',
                        IFINOCTETS       => '2288807394',
                        IFOUTOCTETS      => '3299335483',
                        IFNAME           => 'B4',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CONNECTION => {
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '143',
                                SYSNAME  => '0x0019BB01A600',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.160'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '29',
                        IFDESCR          => 'B5',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(152588) 0:25:25.88',
                        IFSPEED          => '1000000000',
                        MAC              => '00:18:71:C1:F0:E3',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '2809203793',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3318685559',
                        IFNAME           => 'B5',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB058200',
                                IFDESCR  => '141',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.161'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '30',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:E2',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2632) 0:00:26.32',
                        IFSPEED          => '1000000000',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'B6',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'B6'
                    },
                    {
                        IFNUMBER         => '31',
                        IFOUTOCTETS      => '2231577010',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3012845819',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'B7',
                        MAC              => '00:18:71:C1:F0:E1',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(143699) 0:23:56.99',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'B7',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.162',
                                SYSNAME  => '0x0018FEF9A800',
                                IFDESCR  => '285',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '32',
                        IFDESCR          => 'B8',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(143699) 0:23:56.99',
                        IFSPEED          => '1000000000',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:E0',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '3764354101',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3323194516',
                        IFNAME           => 'B8',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.196.162',
                                IFDESCR  => '287',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0018FEF9A800',
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            }
                        },
                    },
                    {
                        IFNUMBER         => '33',
                        IFLASTCHANGE     => '(94732) 0:15:47.32',
                        IFSPEED          => '1000000000',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:DF',
                        IFTYPE           => '6',
                        IFDESCR          => 'B9',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3754573618',
                        IFOUTOCTETS      => '20030667',
                        IFNAME           => 'B9',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IFDESCR  => '285',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x001C2EE58B00',
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.163'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '34',
                        IFNAME           => 'B10',
                        IFOUTERRORS      => '0',
                        IFLASTCHANGE     => '(94732) 0:15:47.32',
                        IFSPEED          => '1000000000',
                        MAC              => '00:18:71:C1:F0:DE',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFDESCR          => 'B10',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFMTU            => '1500',
                        IFINOCTETS       => '1557689030',
                        IFOUTOCTETS      => '2884232004',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MODEL    => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '287',
                                SYSDESCR => 'ProCurve J8698A Switch 5412zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x001C2EE58B00',
                                IP       => '172.31.196.163'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '35',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'B11',
                        IFINOCTETS       => '0',
                        IFMTU            => '0',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:F0:DD',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '36',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        MAC              => '00:18:71:C1:F0:DC',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '0',
                        IFNAME           => 'B12',
                        IFOUTERRORS      => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '37',
                        IFNAME           => 'B13',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'B13',
                        MAC              => '00:18:71:C1:F0:DB',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(137672) 0:22:56.72',
                        IFOUTOCTETS      => '1019288656',
                        IFMTU            => '1500',
                        IFINOCTETS       => '1205644070',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB010B00',
                                IFDESCR  => '118',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.196.140'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '38',
                        IFNAME           => 'B14',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        MAC              => '00:18:71:C1:F0:DA',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '39',
                        IFDESCR          => 'B15',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(139982) 0:23:19.82',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:D9',
                        IFTYPE           => '6',
                        IFOUTOCTETS      => '3131610378',
                        IFINOCTETS       => '2981067194',
                        IFMTU            => '1500',
                        IFNAME           => 'B15',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '118',
                                SYSNAME  => '0x0019BB0D8100',
                                IP       => '172.31.196.141'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '40',
                        IFOUTERRORS      => '0',
                        IFNAME           => 'B16',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        MAC              => '00:18:71:C1:F0:D8',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NAME => 'DEFAULT_VLAN',
                                    NUMBER => '1'
                                }
                            ]
                        },
                    },
                    {
                    IFNUMBER         => '41',
                    IFSTATUS         => '1',
                    IFINTERNALSTATUS => '1',
                    IFDESCR          => 'B17',
                    IFTYPE           => '6',
                    MAC              => '00:18:71:C1:F0:D7',
                    IFINERRORS       => '0',
                    IFSPEED          => '1000000000',
                    IFLASTCHANGE     => '(98347) 0:16:23.47',
                    IFOUTOCTETS      => '1435860196',
                    IFINOCTETS       => '2496990832',
                    IFMTU            => '1500',
                    IFNAME           => 'B17',
                    IFOUTERRORS      => '0',
                    CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                IP       => '172.31.196.142',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '118',
                                SYSNAME  => '0x0016B9138000',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                            }
                        },
                    },
                    {
                        IFNUMBER         => '42',
                        IFNAME           => 'B18',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '2',
                        MAC              => '00:18:71:C1:F0:D6',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME => 'DEFAULT_VLAN'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '43',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'B19',
                        MAC              => '00:18:71:C1:F0:D5',
                        IFINERRORS       => '0',
                        IFTYPE           => '6',
                        IFLASTCHANGE     => '(133655) 0:22:16.55',
                        IFSPEED          => '1000000000',
                        IFOUTOCTETS      => '2304461112',
                        IFINOCTETS       => '3225589631',
                        IFMTU            => '1500',
                        IFNAME           => 'B19',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '118',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0016B9142B00',
                                IP       => '172.31.196.143'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '44',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:D4',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '0',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFNAME           => 'B20',
                        IFOUTERRORS      => '0',
                        VLANS            => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME => 'DEFAULT_VLAN'
                                }
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '45',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'B21',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:F0:D3',
                        IFTYPE           => '6',
                        IFLASTCHANGE     => '(171619) 0:28:36.19',
                        IFSPEED          => '1000000000',
                        IFOUTOCTETS      => '4215478562',
                        IFMTU            => '1500',
                        IFINOCTETS       => '3403667845',
                        IFNAME           => 'B21',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.196.150',
                                SYSNAME  => '0x0019BB1B4D00',
                                IFDESCR  => '118',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '46',
                        IFNAME           => 'B22',
                        IFMTU            => '1500',
                        IFINOCTETS       => '2524887906',
                        IFOUTOCTETS      => '986787144',
                        IFLASTCHANGE     => '(57873) 0:09:38.73',
                        IFSPEED          => '1000000000',
                        MAC              => '00:18:71:C1:F0:D2',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFDESCR          => 'B22',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                SYSNAME  => '0x0019BB172200',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '46',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IP       => '172.31.192.245'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '47',
                        IFNAME           => 'B23',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'B23',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(57873) 0:09:38.73',
                        IFSPEED          => '1000000000',
                        IFTYPE           => '6',
                        MAC              => '00:18:71:C1:F0:D1',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '1527530290',
                        IFINOCTETS       => '1647940696',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CONNECTION => {
                                IP       => '172.31.192.245',
                                SYSNAME  => '0x0019BB172200',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '47',
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))'
                            },
                            CDP => 1
                        },
                    },
                    {
                        IFNUMBER         => '48',
                        IFNAME           => 'B24',
                        IFOUTOCTETS      => '2515291862',
                        IFMTU            => '1500',
                        IFINOCTETS       => '2411859653',
                        IFDESCR          => 'B24',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '1000000000',
                        IFLASTCHANGE     => '(57873) 0:09:38.73',
                        MAC              => '00:18:71:C1:F0:D0',
                        IFTYPE           => '6',
                        IFINERRORS       => '0',
                        IFOUTERRORS      => '0',
                        CONNECTIONS      => {
                            CDP => 1,
                            CONNECTION => {
                                MODEL    => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                SYSNAME  => '0x0019BB172200',
                                SYSDESCR => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_charleston_qaoff))',
                                IFDESCR  => '48',
                                IP       => '172.31.192.245'
                            }
                        },
                    },
                    {
                        IFNUMBER         => '291',
                        IFNAME           => 'Trk2',
                        IFMTU            => '1500',
                        IFLASTCHANGE     => '(140222) 0:23:22.22',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        MAC              => '00:18:71:C1:E0:00',
                        IFDESCR          => 'Trk2',
                        IFSTATUS         => '1',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '3379199007',
                        IFOUTOCTETS      => '410125299',
                        IFSPEED          => '3000000000',
                        IFINTERNALSTATUS => '1',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:19:BB:0D:81:00',
                                    '00:19:BB:0D:91:71',
                                    '00:19:BB:0D:91:73',
                                    '00:19:BB:0D:91:8A',
                                    '00:05:1E:BF:07:E0',
                                    '00:50:56:00:00:06',
                                    '00:50:56:70:C4:44',
                                    '00:50:56:7B:AA:A5',
                                    '00:50:56:46:51:9D',
                                    '00:50:56:49:71:8C',
                                    '02:A0:98:12:B5:20'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '3000',
                                    NAME   => 'COLLECTE-TEST'
                                },
                                {
                                    NUMBER => '3002',
                                    NAME => 'TEST-APPLI',
                                },
                                {
                                    NUMBER => '3006',
                                    NAME => 'TEST-AGRIATE',
                                },
                                {
                                    NUMBER => '3007',
                                    NAME   => 'TEST-ETAB',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '293',
                        IFNAME           => 'Trk4',
                        IFMTU            => '1500',
                        IFLASTCHANGE     => '(152649) 0:25:26.49',
                        IFTYPE           => '161',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFDESCR          => 'Trk4',
                        IFSTATUS         => '1',
                        IFINOCTETS       => '3667291251',
                        IFOUTOCTETS      => '949597094',
                        IFSPEED          => '3000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                        CONNECTIONS => {
                            CONNECTION => {
                                MAC => [
                                    '00:00:F0:AC:EA:A9',
                                    '00:19:BB:05:82:00',
                                    '00:19:BB:05:92:73',
                                    '00:19:BB:05:92:8A',
                                    '00:19:DB:A9:28:04',
                                    '00:1E:68:5D:33:46',
                                    '00:1E:68:5E:3D:B6',
                                    '00:21:5A:97:2A:B7',
                                    '00:22:F3:9D:20:4B',
                                    '00:22:F3:C7:D7:8B',
                                    '00:23:7D:76:E3:8C',
                                    '00:25:B3:F4:FC:F6',
                                    '00:26:22:D3:A0:29',
                                    '00:08:5D:13:57:D2',
                                    '00:08:5D:2B:65:12',
                                    '00:08:5D:2C:C0:02',
                                    '10:78:D2:E8:73:41'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '295',
                        IFNAME           => 'Trk6',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '3000000000',
                        IFOUTOCTETS      => '4031062390',
                        IFINOCTETS       => '3539810853',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFDESCR          => 'Trk6',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '161',
                        IFLASTCHANGE     => '(147706) 0:24:37.06',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:00:F0:A9:62:13',
                                    '00:0B:84:00:6C:8A',
                                    '00:13:72:F6:E2:4E',
                                    '00:14:7C:2B:86:20',
                                    '00:16:17:C2:E9:F0',
                                    '00:18:71:85:A3:9B',
                                    '00:19:BB:1A:CC:00',
                                    '00:19:BB:1A:DC:71',
                                    '00:19:BB:1A:DC:73',
                                    '00:19:BB:1A:DC:8A',
                                    '00:19:DB:7A:B6:94',
                                    '00:19:DB:88:99:46',
                                    '00:19:DB:BC:81:F8',
                                    '00:19:DB:BC:82:F3',
                                    '00:1A:4B:19:26:0D',
                                    '00:1D:92:DC:F6:68',
                                    '00:1D:92:DD:6B:F0',
                                    '00:1D:92:DF:6F:AE',
                                    '00:1F:29:99:CB:BB',
                                    '00:1F:29:99:DB:41',
                                    '00:1F:29:14:87:74',
                                    '00:21:85:D0:32:C9',
                                    '00:21:85:D0:32:08',
                                    '00:21:85:D0:33:7B',
                                    '00:22:F3:9D:1F:C7',
                                    '00:22:F3:C7:D7:86',
                                    '00:22:F3:C8:02:CF',
                                    '00:22:F3:C8:02:2E',
                                    '00:22:F3:C8:04:16',
                                    '00:23:EA:DB:05:48',
                                    '00:23:47:25:AA:C0',
                                    '00:04:00:9D:44:34',
                                    '00:04:00:B9:19:C4',
                                    '00:04:00:CD:D3:85',
                                    '00:08:5D:86:D5:65',
                                    '00:08:5D:86:D7:64',
                                    '00:08:5D:13:42:22',
                                    '00:08:5D:13:56:D1',
                                    '00:08:5D:13:57:E1',
                                    '00:08:5D:13:57:F4',
                                    '00:08:5D:13:58:16',
                                    '00:08:5D:13:58:1B',
                                    '00:08:5D:13:58:1C',
                                    '00:08:5D:13:58:1D',
                                    '00:08:5D:13:58:1E',
                                    '00:08:5D:13:58:1F',
                                    '00:08:5D:13:58:22',
                                    '00:08:5D:13:58:25',
                                    '00:08:5D:13:59:97',
                                    '00:08:5D:1B:73:36',
                                    '00:08:5D:1B:75:0F',
                                    '00:08:5D:1B:75:14',
                                    '00:08:5D:1B:7B:33',
                                    '00:08:5D:24:CE:50',
                                    '00:08:5D:24:CF:84',
                                    '00:08:5D:24:CF:89',
                                    '00:08:5D:24:CF:A4',
                                    '00:08:5D:24:CF:5F',
                                    '00:08:5D:24:CF:62',
                                    '00:08:5D:2B:F1:8B',
                                    '00:08:5D:2B:F1:91',
                                    '00:08:5D:2C:C2:68',
                                    '00:50:FC:6D:A5:52',
                                    '00:60:2E:02:13:61',
                                    '10:78:D2:E3:8B:91',
                                    '10:78:D2:E3:8B:B9',
                                    '10:78:D2:E6:DF:CB',
                                    '10:78:D2:E9:8F:BC',
                                    '10:1F:74:47:EF:CF',
                                    'B8:AC:6F:23:1A:05',
                                    'B8:AC:6F:25:C8:40',
                                    'B8:AC:6F:3E:36:5F',
                                    '08:00:71:03:DD:41',
                                    '08:2E:5F:32:7A:91'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '297',
                        IFNAME           => 'Trk8',
                        IFLASTCHANGE     => '(171701) 0:28:37.01',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        IFDESCR          => 'Trk8',
                        IFSTATUS         => '1',
                        IFMTU            => '1500',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '3000000000',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '2716694799',
                        IFOUTOCTETS      => '3066835333',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:0B:82:08:65:49',
                                    '00:0B:84:00:6D:33',
                                    '00:11:0A:FC:D2:D4',
                                    '00:16:17:5C:BE:45',
                                    '00:E0:D8:0A:A8:E1',
                                    '00:E0:D8:0A:A8:E2',
                                    '00:E0:D8:0A:2E:1F',
                                    '00:18:FE:A5:0D:FD',
                                    '00:19:BB:1B:4D:00',
                                    '00:19:BB:1B:5D:71',
                                    '00:19:BB:1B:5D:73',
                                    '00:19:BB:1B:5D:8A',
                                    '00:19:DB:7A:B5:F3',
                                    '00:19:DB:C0:D8:AE',
                                    '00:1D:92:DC:F6:BA',
                                    '00:1D:92:DD:74:B6',
                                    '00:1F:29:25:4C:AD',
                                    '00:22:F3:C7:D6:A2',
                                    '00:23:18:91:DB:8D',
                                    '00:24:21:0C:3A:FB',
                                    '00:24:21:0C:3D:6A',
                                    '00:24:21:0C:3D:5B',
                                    '00:04:F2:E4:26:4F',
                                    '00:08:5D:1B:7B:25',
                                    '00:08:5D:1B:7B:2D',
                                    '00:08:5D:1B:7B:34',
                                    '00:08:5D:1B:7B:38',
                                    '00:08:5D:1B:7C:66',
                                    '00:08:5D:2C:C7:00',
                                    '00:08:5D:2C:C7:1F',
                                    '00:08:5D:2C:C7:32',
                                    '10:78:D2:E3:8B:C7',
                                    '10:78:D2:E6:E2:78',
                                    'B8:AC:6F:23:19:08'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '299',
                        IFNAME           => 'Trk10',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'Trk10',
                        IFSTATUS         => '1',
                        IFLASTCHANGE     => '(143756) 0:23:57.56',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '161',
                        IFMTU            => '1500',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '3000000000',
                        IFOUTOCTETS      => '3487158309',
                        IFINOCTETS       => '2069762898',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:14:38:4A:D0:31',
                                    '00:16:17:A5:09:24',
                                    '00:16:17:C4:6E:55',
                                    '00:16:17:E3:9C:68',
                                    '00:16:17:E3:23:EE',
                                    '00:17:08:86:1A:84',
                                    '00:18:71:88:A6:54',
                                    '00:18:FE:F9:A8:00',
                                    '00:18:FE:F9:A8:E1',
                                    '00:18:FE:F9:A8:E3',
                                    '00:18:FE:F9:A8:FA',
                                    '00:1B:78:25:73:B6',
                                    '00:1B:78:09:58:79',
                                    '00:1D:92:DD:6B:EC',
                                    '00:1D:92:DD:6F:B1',
                                    '00:1D:92:DD:75:8E',
                                    '00:1E:0B:0C:89:DB',
                                    '00:1F:29:99:BB:9D',
                                    '00:1F:29:16:44:44',
                                    '00:21:85:D0:32:F9',
                                    '00:22:F3:9D:0F:D9',
                                    '00:22:F3:9D:20:56',
                                    '00:22:F3:C7:D8:20',
                                    '00:04:00:9D:84:A8',
                                    '00:04:00:9D:F8:E0',
                                    '00:04:00:AD:E9:50',
                                    '00:08:5D:13:57:05',
                                    '00:08:5D:2C:C0:6A',
                                    '00:08:5D:2C:C0:CF',
                                    '00:08:5D:2C:C0:27',
                                    '10:78:D2:E9:8E:4B',
                                    'B8:AC:6F:22:AA:E0'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },
                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '301',
                        IFNAME           => 'Trk12',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '3000000000',
                        IFOUTOCTETS      => '2720306505',
                        IFINOCTETS       => '982784258',
                        IFSTATUS         => '1',
                        IFDESCR          => 'Trk12',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        MAC              => '00:18:71:C1:E0:00',
                        IFLASTCHANGE     => '(137833) 0:22:58.33',
                        IFMTU            => '1500',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:19:BB:01:0B:00',
                                    '00:19:BB:01:1B:71',
                                    '00:19:BB:01:1B:73',
                                    '00:19:BB:01:1B:8A',
                                    '00:50:56:72:2C:1A',
                                    '00:50:56:7E:E7:85',
                                    '00:50:56:8B:65:0A',
                                    '00:50:56:8B:29:26',
                                    '00:50:56:44:71:B5',
                                    '00:50:56:47:E1:B4'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '3000',
                                    NAME   => 'COLLECTE-TEST'
                                },
                                {
                                    NUMBER => '3002',
                                    NAME => 'TEST-APPLI',
                                },
                                {
                                    NUMBER => '3006',
                                    NAME => 'TEST-AGRIATE',
                                },
                                {
                                    NUMBER => '3007',
                                    NAME   => 'TEST-ETAB',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '303',
                        IFNAME           => 'Trk14',
                        IFOUTOCTETS      => '551488736',
                        IFOUTERRORS      => '0',
                        IFLASTCHANGE     => '(133781) 0:22:17.81',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        IFDESCR          => 'Trk14',
                        IFSTATUS         => '1',
                        IFMTU            => '1500',
                        IFSPEED          => '3000000000',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '1935734813',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:16:B9:14:2B:00',
                                    '00:16:B9:14:3B:71',
                                    '00:16:B9:14:3B:73',
                                    '00:16:B9:14:3B:8A',
                                    '00:1E:C9:B7:B8:B3',
                                    '00:1E:C9:B7:B8:F4',
                                    '00:50:56:72:D9:74',
                                    '00:50:56:44:DF:2D'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '3000',
                                    NAME   => 'COLLECTE-TEST'
                                },
                                {
                                    NUMBER => '3002',
                                    NAME => 'TEST-APPLI',
                                },
                                {
                                    NUMBER => '3006',
                                    NAME => 'TEST-AGRIATE',
                                },
                                {
                                    NUMBER => '3007',
                                    NAME   => 'TEST-ETAB',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '305',
                        IFNAME           => 'Trk16',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFDESCR          => 'Trk16',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        IFLASTCHANGE     => '(98455) 0:16:24.55',
                        IFMTU            => '1500',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '3000000000',
                        IFOUTOCTETS      => '827902268',
                        IFINOCTETS       => '1672200058',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:16:B9:13:80:00',
                                    '00:16:B9:13:90:71',
                                    '00:16:B9:13:90:73',
                                    '00:16:B9:13:90:8A',
                                    '00:E0:86:07:6B:79',
                                    '00:05:1E:BD:62:DB',
                                    '00:50:56:73:17:D4',
                                    '00:50:56:76:7E:16',
                                    '00:50:56:76:FC:2F',
                                    '00:50:56:8B:72:94',
                                    '00:50:56:8B:45:38',
                                    '00:50:56:42:5B:6B',
                                    '00:50:56:4D:F7:97',
                                    '00:50:56:4F:3B:1C',
                                    '02:A0:98:12:7A:68'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '3000',
                                    NAME   => 'COLLECTE-TEST'
                                },
                                {
                                    NUMBER => '3002',
                                    NAME => 'TEST-APPLI',
                                },
                                {
                                    NUMBER => '3006',
                                    NAME => 'TEST-AGRIATE',
                                },
                                {
                                    NUMBER => '3007',
                                    NAME   => 'TEST-ETAB',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '307',
                        IFNAME           => 'Trk18',
                        IFINOCTETS       => '3960692883',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFDESCR          => 'Trk18',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        IFLASTCHANGE     => '(94806) 0:15:48.06',
                        IFMTU            => '1500',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '3000000000',
                        IFOUTOCTETS      => '3913938745',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:00:85:BB:5F:E9',
                                    '00:14:38:E1:1D:33',
                                    '00:15:99:1F:52:CD',
                                    '00:16:17:E2:35:6A',
                                    '00:19:DB:A7:6F:DC',
                                    '00:19:DB:A7:70:84',
                                    '00:19:DB:AA:F4:65',
                                    '00:19:DB:AD:68:BB',
                                    '00:19:DB:BC:82:DC',
                                    '00:1A:4B:32:21:62',
                                    '00:1C:2E:E5:8B:00',
                                    '00:1C:2E:E5:8B:E1',
                                    '00:1C:2E:E5:8B:E3',
                                    '00:1C:2E:E5:8B:FA',
                                    '00:1D:92:DD:6B:F5',
                                    '00:1D:92:DD:6E:3B',
                                    '00:1D:92:DD:75:F5',
                                    '00:1D:92:DD:76:D1',
                                    '00:1F:29:16:34:B2',
                                    '00:21:85:D0:32:DD',
                                    '00:22:F3:9D:1B:8F',
                                    '00:22:F3:C7:D7:03',
                                    '00:22:F3:C8:04:99',
                                    '00:23:7D:75:A5:00',
                                    '00:23:7D:76:E3:42',
                                    '00:25:B3:F4:EC:86',
                                    '00:04:00:67:C7:7C',
                                    '00:04:00:9C:6C:25',
                                    '00:30:05:5D:68:4F',
                                    '00:08:5D:13:42:8C',
                                    '00:08:5D:24:D0:DD',
                                    '00:08:5D:2C:C0:D2',
                                    '78:E7:D1:AA:AF:A3',
                                    '10:78:D2:E3:8B:66',
                                    'B8:AC:6F:25:D9:BC',
                                    'B8:AC:6F:3E:3B:09',
                                    'F0:DE:F1:00:E3:76',
                                    'F0:DE:F1:00:E3:C5',
                                    '1C:75:08:75:F0:C2',
                                    '1C:C1:DE:CB:7D:95',
                                    '44:1E:A1:34:0B:A0'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '309',
                        IFNAME           => 'Trk20',
                        IFINOCTETS       => '297423068',
                        IFOUTOCTETS      => '3730410035',
                        IFLASTCHANGE     => '(154845) 0:25:48.45',
                        IFINERRORS       => '0',
                        IFTYPE           => '161',
                        MAC              => '00:18:71:C1:E0:00',
                        IFDESCR          => 'Trk20',
                        IFSTATUS         => '1',
                        IFMTU            => '1500',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '3000000000',
                        IFINTERNALSTATUS => '1',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:0B:84:00:1F:7D',
                                    '00:13:21:EF:3F:59',
                                    '00:16:76:2D:72:2F',
                                    '00:16:35:65:BF:8C',
                                    '00:19:BB:01:A6:00',
                                    '00:19:BB:01:B6:71',
                                    '00:19:BB:01:B6:73',
                                    '00:19:BB:01:B6:8A',
                                    '00:1D:92:DC:F5:DE',
                                    '00:1D:92:DD:6B:C6',
                                    '00:1D:92:DD:6B:D5',
                                    '00:1D:92:DD:6B:E0',
                                    '00:1F:29:28:88:E4',
                                    '00:21:5A:7C:EC:35',
                                    '00:21:5A:97:1B:32',
                                    '00:22:F3:9D:1F:3B',
                                    '00:08:5D:2B:F1:48',
                                    'B8:AC:6F:3E:3A:C5'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '310',
                        IFNAME           => 'Trk21',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '2695065174',
                        IFOUTOCTETS      => '2418744384',
                        IFSPEED          => '4294967295',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '1500',
                        IFTYPE           => '161',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(57970) 0:09:39.70',
                        IFSTATUS         => '1',
                        IFDESCR          => 'Trk21',
                        CONNECTIONS      => {
                            CONNECTION => {
                                MAC => [
                                    '00:00:00:00:FE:00',
                                    '00:00:00:00:FE:01',
                                    '00:00:5E:00:01:01',
                                    '00:00:5E:00:01:0A',
                                    '00:00:5E:00:01:0B',
                                    '00:00:5E:00:01:0C',
                                    '00:00:5E:00:01:0D',
                                    '00:00:5E:00:01:02',
                                    '00:00:5E:00:01:17',
                                    '00:00:5E:00:01:1A',
                                    '00:00:5E:00:01:1B',
                                    '00:00:5E:00:01:1E',
                                    '00:00:5E:00:01:1F',
                                    '00:00:5E:00:01:07',
                                    '00:00:5E:00:01:08',
                                    '00:0C:29:21:58:A3',
                                    '00:0D:A2:10:26:66',
                                    '00:90:FB:2E:03:32',
                                    '00:90:FB:2E:03:33',
                                    '00:90:FB:2E:03:34',
                                    '00:90:FB:2E:03:35',
                                    '00:90:FB:2E:03:36',
                                    '00:12:F2:7C:72:30',
                                    '00:12:F2:7C:39:D0',
                                    '00:13:7F:F5:55:D8',
                                    '00:13:D4:81:69:4B',
                                    '00:14:5E:DE:C3:4F',
                                    '00:19:BB:17:22:00',
                                    '00:19:BB:17:32:D0',
                                    '00:19:BB:17:32:D1',
                                    '00:19:BB:17:32:D2',
                                    '00:19:BB:17:32:E8',
                                    '00:19:BB:17:32:E9',
                                    '00:19:BB:17:32:EA',
                                    '00:1A:4B:30:67:61',
                                    '00:03:A0:8A:52:18',
                                    '00:1E:C9:B9:0C:6E',
                                    '00:1E:C9:B9:11:CD',
                                    '00:22:19:5C:65:F6',
                                    '00:26:B9:8A:F1:0A',
                                    '00:26:B9:8E:4A:11',
                                    '00:30:05:38:78:53',
                                    '00:30:05:38:78:5B',
                                    '00:50:56:00:00:01',
                                    '00:50:56:00:00:02',
                                    '00:50:56:00:00:03',
                                    '00:50:56:00:00:04',
                                    '00:50:56:00:00:08',
                                    '00:50:56:8B:64:98',
                                    '00:50:56:8B:64:F3',
                                    '00:50:56:8B:68:41',
                                    '00:50:56:8B:6A:F8',
                                    '00:50:56:8B:6B:43',
                                    '00:50:56:8B:70:48',
                                    '00:50:56:8B:72:CB',
                                    '00:50:56:8B:76:A6',
                                    '00:50:56:8B:78:F1',
                                    '00:50:56:8B:7E:A7',
                                    '00:50:56:8B:7F:71',
                                    '00:50:56:8B:0E:1F',
                                    '00:50:56:8B:10:D2',
                                    '00:50:56:8B:13:0E',
                                    '00:50:56:8B:1B:1B',
                                    '00:50:56:8B:1D:11',
                                    '00:50:56:8B:03:D4',
                                    '00:50:56:8B:21:BA',
                                    '00:50:56:8B:23:4F',
                                    '00:50:56:8B:24:E6',
                                    '00:50:56:8B:29:6D',
                                    '00:50:56:8B:30:70',
                                    '00:50:56:8B:32:35',
                                    '00:50:56:8B:35:1C',
                                    '00:50:56:8B:38:FE',
                                    '00:50:56:8B:3A:66',
                                    '00:50:56:8B:3E:65',
                                    '00:50:56:8B:42:2B',
                                    '00:50:56:8B:4D:90',
                                    '00:50:56:8B:52:11',
                                    '00:50:56:8B:5C:9A',
                                    '00:50:56:8B:5D:3F',
                                    '00:50:56:8B:5E:39',
                                    '00:09:0F:09:3F:02',
                                    '00:09:0F:09:3F:03',
                                    '00:09:0F:09:3F:04',
                                    '02:12:F2:7C:72:3A',
                                    '02:12:F2:7C:72:3B',
                                    '02:12:F2:7C:72:3C',
                                    '02:12:F2:7C:72:3D',
                                    '02:12:F2:7C:72:3E',
                                    '02:12:F2:7C:72:3F',
                                    '02:12:F2:7C:39:DA',
                                    '02:12:F2:7C:39:DB',
                                    '02:12:F2:7C:39:DC',
                                    '02:12:F2:7C:39:DD',
                                    '02:12:F2:7C:39:DE',
                                    '02:12:F2:7C:39:DF',
                                    '02:12:F2:A8:DF:FA',
                                    '02:12:F2:A8:DF:FB',
                                    '02:12:F2:62:E2:22',
                                    '02:12:F2:62:E2:23',
                                    '02:12:F2:62:E2:24',
                                    '02:12:F2:62:E2:26',
                                    '02:12:F2:62:E2:27',
                                    '02:12:F2:62:E2:28',
                                    '02:12:F2:62:E2:29',
                                    '02:12:F2:62:E2:2A',
                                    '02:12:F2:62:E2:2B',
                                    '02:12:F2:62:E2:2C',
                                    '02:12:F2:62:E2:2D',
                                    '02:12:F2:62:E2:2E',
                                    '02:12:F2:62:E2:2F',
                                    '02:12:F2:62:E2:30',
                                    '02:12:F2:62:E2:31',
                                    '02:12:F2:62:E2:32',
                                    '02:12:F2:62:E2:33',
                                    '02:12:F2:62:E2:34',
                                    '02:12:F2:62:E2:35',
                                    '02:12:F2:62:E2:36',
                                    '02:12:F2:62:E2:39',
                                    '02:12:F2:62:E2:3A',
                                    '02:12:F2:62:E2:3B',
                                    '02:E0:52:76:0E:16',
                                    '02:E0:52:20:5E:10',
                                    'D4:BE:D9:AF:75:1B'
                                ]
                            }
                        },
                        VLANS => {
                            VLAN => [
                                {
                                    NUMBER => '1',
                                    NAME   => 'DEFAULT_VLAN'
                                },
                                {
                                    NUMBER => '13',
                                    NAME   => 'VOIP_ASTERISK',
                                },
                                {
                                    NUMBER => '14',
                                    NAME   => 'DMZ227',
                                },
                                {
                                    NUMBER => '149',
                                    NAME   => 'COLLECTE_IP_RIHDA',
                                },
                                {
                                    NUMBER => '15',
                                    NAME   => 'INTERCO-CSS'
                                },
                                {
                                    NUMBER => '150',
                                    NAME   => 'RENATER'
                                },

                                {
                                    NUMBER => '152',
                                    NAME   => 'FW-DMZ-INFRA',
                                },
                                {
                                    NUMBER => '153',
                                    NAME   => 'FW-VLAN-LIBRE'
                                },
                                {
                                    NUMBER => '154',
                                    NAME   => 'FW-INTERCO-FOUNDRY'
                                },
                                {
                                    NUMBER => '155',
                                    NAME   => 'FW-DMZ',
                                },
                                {
                                    NUMBER => '156',
                                    NAME   => 'FW-Libre_Service',
                                },
                                {
                                    NUMBER => '157',
                                    NAME   => 'FW-DMZ-PEDA',
                                },
                                {
                                    NUMBER => '158',
                                    NAME   => 'FW-DMZ-INFRA2'
                                },
                                {
                                    NUMBER => '159',
                                    NAME   => 'FW-PUG-DRRT',
                                },
                                {
                                    NUMBER => '16',
                                    NAME   => 'SERVEUR-CSS'
                                },
                                {
                                    NUMBER => '160',
                                    NAME   => 'ToIP_RIHDA'
                                },
                                {
                                    NUMBER => '162',
                                    NAME   => 'LIBR_SERVICE'
                                },
                                {
                                    NUMBER => '17',
                                    NAME => 'INTER_EQUANT_RECTORAT'
                                },
                                {
                                    NUMBER => '170',
                                    NAME   => 'DATA_RIHDA'
                                },
                                {
                                    NUMBER => '171',
                                    NAME   => 'DATA_POLY'
                                },
                                {
                                    NUMBER => '172',
                                    NAME   => 'DATA_CEPE',
                                },
                                {
                                    NUMBER => '18',
                                    NAME   => 'INT_EQUANT_ETABLISSEMENTS',
                                },
                                {
                                    NUMBER => '180',
                                    NAME   => 'video_RIHDA'
                                },
                                {
                                    NUMBER => '190',
                                    NAME   => 'postesIP_RIHDA'
                                },
                                {
                                    NUMBER => '196',
                                    NAME   => 'ADMIN_RESEAU',
                                },
                                {
                                    NUMBER => '2',
                                    NAME => 'SERVERS',
                                },
                                {
                                    NUMBER => '201',
                                    NAME   => 'PERIPHERIQUES',
                                },
                                {
                                    NUMBER => '202',
                                    NAME   => 'UTIL_NVEAU_BAT',
                                },
                                {
                                    NUMBER => '204',
                                    NAME   => 'UTIL_FORMATION'
                                },
                                {
                                    NUMBER => '205',
                                    NAME   => 'UTIL_CATI'
                                },
                                {
                                    NUMBER => '214',
                                    NAME   => 'UTIL_INVITES',
                                },
                                {
                                    NUMBER => '215',
                                    NAME   => 'UTIL_SYST_RESEAUX'
                                },
                                {
                                    NUMBER => '22',
                                    NAME   => 'DMZ_HD'
                                },
                                {
                                    NUMBER => '3',
                                    NAME => 'ZONE_PUBLIQUE',
                                },
                                {
                                    NUMBER => '30',
                                    NAME   => 'RESEAU_DRRT-PUG',
                                },
                                {
                                    NUMBER => '4',
                                    NAME   => 'INTERCO_RACINE_API',
                                },
                                {
                                    NAME   => 'VLAN401',
                                    NUMBER => '401',
                                },
                                {
                                    NUMBER => '402',
                                    NAME   => 'wifi_recteur'
                                },
                                {
                                    NUMBER => '403',
                                    NAME   => 'DMZ_ELGG'
                                },
                                {
                                    NUMBER => '5',
                                    NAME   => 'DMZ'
                                },
                                {
                                    NUMBER => '6',
                                    NAME   => 'AGRIATES'
                                },
                                {
                                    NUMBER => '7',
                                    NAME   => 'ACCUEIL_ETABLISSEMENTS',
                                },
                            ]
                        },
                    },
                    {
                        IFNUMBER         => '578',
                        IFNAME           => 'DEFAULT_VLAN',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'DEFAULT_VLAN',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500'
                    },
                    {
                        IFNUMBER         => '579',
                        IFNAME           => 'VLAN2',
                        IFOUTERRORS      => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFDESCR          => 'VLAN2',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53'
                    },
                    {
                        IFNUMBER         => '580',
                        IFNAME           => 'VLAN3',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN3',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '581',
                        IFNAME           => 'VLAN4',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN4',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '582',
                        IFNAME           => 'VLAN5',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'VLAN5',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500'
                    },
                    {
                        IFNUMBER         => '583',
                        IFNAME           => 'VLAN6',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'VLAN6',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500'
                    },
                    {
                        IFNUMBER         => '584',
                        IFNAME           => 'VLAN7',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN7',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '590',
                        IFNAME           => 'VLAN13',
                        IFOUTERRORS      => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN13',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500'
                    },
                    {
                        IFNUMBER         => '591',
                        IFNAME           => 'VLAN14',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFDESCR          => 'VLAN14',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '592',
                        IFNAME           => 'VLAN15',
                        IFOUTERRORS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN15',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0'
                    },
                    {
                        IFNUMBER         => '593',
                        IFNAME           => 'VLAN16',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN16',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '594',
                        IFNAME           => 'VLAN17',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN17',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '595',
                        IFNAME           => 'VLAN18',
                        IFDESCR          => 'VLAN18',
                        IFOUTERRORS      => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0'
                    },
                    {
                        IFNUMBER         => '599',
                        IFNAME           => 'VLAN22',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN22',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '607',
                        IFNAME           => 'VLAN30',
                        IFOUTERRORS      => '0',
                        IFDESCR          => 'VLAN30',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0'
                    },
                    {
                        IFNUMBER         => '726',
                        IFNAME           => 'VLAN149',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN149',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '727',
                        IFNAME           => 'VLAN150',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN150',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '729',
                        IFNAME           => 'VLAN152',
                        IFOUTERRORS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN152'
                    },
                    {
                        IFNUMBER         => '730',
                        IFNAME           => 'VLAN153',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN153',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500'
                    },
                    {
                        IFNUMBER         => '731',
                        IFNAME           => 'VLAN154',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN154'
                    },
                    {
                        IFNUMBER         => '732',
                        IFNAME           => 'VLAN155',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN155'
                    },
                    {
                        IFNUMBER         => '733',
                        IFNAME           => 'VLAN156',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFDESCR          => 'VLAN156',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '734',
                        IFNAME           => 'VLAN157',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN157',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNAME           => 'VLAN158',
                        IFNUMBER         => '735',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN158',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '736',
                        IFNAME           => 'VLAN159',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN159',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '737',
                        IFNAME           => 'VLAN160',
                        IFOUTERRORS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFDESCR          => 'VLAN160',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1'
                    },
                    {
                        IFNUMBER         => '739',
                        IFNAME           => 'VLAN162',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(110183700) 12 days, 18:03:57.00',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN162',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '747',
                        IFNAME           => 'VLAN170',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN170',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '748',
                        IFNAME           => 'VLAN171',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN171',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0'
                    },
                    {
                        IFNUMBER         => '749',
                        IFNAME           => 'VLAN172',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN172'
                    },
                    {
                        IFNUMBER         => '757',
                        IFNAME           => 'VLAN180',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN180',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '767',
                        IFNAME           => 'VLAN190',
                        IFOUTERRORS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN190'
                    },
                    {
                        IFNUMBER         => '773',
                        IFNAME           => 'VLAN196',
                        IFDESCR          => 'VLAN196',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '778',
                        IFNAME           => 'VLAN201',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN201',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '779',
                        IFNAME           => 'VLAN202',
                        IFOUTERRORS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN202',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0'
                    },
                    {
                        IFNUMBER         => '781',
                        IFNAME           => 'VLAN204',
                        IFOUTERRORS      => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSPEED          => '0',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFDESCR          => 'VLAN204',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0'
                    },
                    {
                        IFNUMBER         => '782',
                        IFNAME           => 'VLAN205',
                        IFOUTERRORS      => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFDESCR          => 'VLAN205',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53'
                    },
                    {
                        IFNUMBER         => '791',
                        IFNAME           => 'VLAN214',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN214',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '792',
                        IFNAME           => 'VLAN215',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2663) 0:00:26.63',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN215',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '978',
                        IFNAME           => 'VLAN401',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTOCTETS      => '0',
                        IFLASTCHANGE     => '(110183690) 12 days, 18:03:56.90',
                        IFSPEED          => '0',
                        IFTYPE           => '53',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFDESCR          => 'VLAN401',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '979',
                        IFNAME           => 'VLAN402',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN402',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '980',
                        IFNAME           => 'VLAN403',
                        IFDESCR          => 'VLAN403',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFLASTCHANGE     => '(2658) 0:00:26.58',
                        IFSPEED          => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '3577',
                        IFNAME           => 'VLAN3000',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN3000',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(57880) 0:09:38.80',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '1500',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '3579',
                        IFNAME           => 'VLAN3002',
                        IFOUTERRORS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(57880) 0:09:38.80',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN3002'
                    },
                    {
                        IFNUMBER         => '3583',
                        IFNAME           => 'VLAN3006',
                        IFOUTERRORS      => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'VLAN3006',
                        IFINERRORS       => '0',
                        MAC              => '00:18:71:C1:E0:00',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(57880) 0:09:38.80',
                        IFSPEED          => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0'
                    },
                    {
                        IFNUMBER         => '3584',
                        IFNAME           => 'VLAN3007',
                        IFOUTERRORS      => '0',
                        IFOUTOCTETS      => '0',
                        IFMTU            => '1500',
                        IFINOCTETS       => '0',
                        IFINTERNALSTATUS => '1',
                        IFSTATUS         => '1',
                        IFDESCR          => 'VLAN3007',
                        MAC              => '00:18:71:C1:E0:00',
                        IFINERRORS       => '0',
                        IFTYPE           => '53',
                        IFLASTCHANGE     => '(57880) 0:09:38.80',
                        IFSPEED          => '0'
                    },
                    {
                        IFNUMBER         => '4672',
                        IFNAME           => 'lo0',
                        IFMTU            => '65535',
                        IFINOCTETS       => '7893971',
                        IFOUTOCTETS      => '7774747',
                        IFTYPE           => '24',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFSTATUS         => '1',
                        IFINTERNALSTATUS => '1',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '4673',
                        IFNAME           => 'lo1',
                        IFOUTERRORS      => '0',
                        IFMTU            => '9198',
                        IFINOCTETS       => '0',
                        IFOUTOCTETS      => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFINERRORS       => '0',
                        IFTYPE           => '24',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '2',
                    },
                    {
                        IFNUMBER         => '4674',
                        IFNAME           => 'lo2',
                        IFOUTERRORS      => '0',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '2',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFTYPE           => '24',
                        IFINERRORS       => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0'
                    },
                    {
                        IFNUMBER         => '4675',
                        IFNAME           => 'lo3',
                        IFINERRORS       => '0',
                        IFTYPE           => '24',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFINTERNALSTATUS => '2',
                        IFSTATUS         => '2',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '4676',
                        IFNAME           => 'lo4',
                        IFOUTOCTETS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '2',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFTYPE           => '24',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFOUTERRORS      => '0',
                    },
                    {
                        IFNUMBER         => '4677',
                        IFNAME           => 'lo5',
                        IFTYPE           => '24',
                        IFINERRORS       => '0',
                        IFSPEED          => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSTATUS         => '2',
                        IFINTERNALSTATUS => '2',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFOUTOCTETS      => '0',
                        IFOUTERRORS      => '0'
                    },
                    {
                        IFNUMBER         => '4678',
                        IFNAME           => 'lo6',
                        IFOUTERRORS      => '0',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFOUTOCTETS      => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFTYPE           => '24',
                        IFINERRORS       => '0',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFINTERNALSTATUS => '2',
                        IFSTATUS         => '2',
                    },
                    {
                        IFNUMBER         => '4679',
                        IFNAME           => 'lo7',
                        IFINOCTETS       => '0',
                        IFMTU            => '9198',
                        IFOUTOCTETS      => '0',
                        IFLASTCHANGE     => '(0) 0:00:00.00',
                        IFSPEED          => '0',
                        IFINERRORS       => '0',
                        IFTYPE           => '24',
                        IFDESCR          => 'HP ProCurve Switch software loopback interface',
                        IFINTERNALSTATUS => '2',
                        IFSTATUS         => '2',
                        IFOUTERRORS      => '0',
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_CP1025nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            SNMPHOSTNAME => 'NPIA6032E',
            MAC          => '78:E7:D1:A6:03:2E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            SNMPHOSTNAME => 'NPIA6032E',
            MAC          => '78:E7:D1:A6:03:2E',
            MODELSNMP    => 'Printer0532',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                MODEL        => 'HP LaserJet CP1025nw',
                LOCATION     => ' ',
                ID           => undef,
                NAME         => 'NPIA6032E'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'LOOPBACK',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'NetDrvr',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '78:E7:D1:A6:03:2E'
                    }
                ]
            },
            PAGECOUNTERS => {
                BLACK      => '91',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => '00:21:5A:7A:5E:2D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => '00:21:5A:7A:5E:2D',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4831523036363335'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P3005',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                NAME         => 'NPI7A5E2D',
                SERIAL       => 'CNH1R06635',
                MODEL        => '0x0115513738313441'
            },
            CARTRIDGES => {
                TONERBLACK => 32
            },
            PAGECOUNTERS => {
                RECTOVERSO => '0',
                PRINTTOTAL => '20949',
            }
        }
    ],
    'hewlett-packard/LaserJet_P3005.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI91B509',
            MAC          => '00:17:08:91:B5:09',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI91B509',
            MAC          => '00:17:08:91:B5:09',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447333853',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI91B509',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG38S',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '98',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1',
                PRINTTOTAL => '150',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI947D4C',
            MAC          => '00:17:A4:94:7D:4C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI947D4C',
            MAC          => '00:17:A4:94:7D:4C',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E465736444630574C',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI947D4C',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DF0WL',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '10',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1',
                PRINTTOTAL => '13324',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'L0420a',
            MAC          => '00:17:A4:93:4D:9F',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'L0420a',
            MAC          => '00:17:A4:93:4D:9F',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447333951',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'L0420a',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG39Q',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '70',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '566',
                PRINTTOTAL => '13193',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l0500a',
            MAC          => '00:17:08:91:95:DD',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l0500a',
            MAC          => '00:17:08:91:95:DD',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E465736444733384C',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'l0500a',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG38L',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '36',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '105',
                PRINTTOTAL => '15807',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D69',
            MAC          => '00:17:A4:93:4D:69',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D69',
            MAC          => '00:17:A4:93:4D:69',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447334450',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI934D69',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG3DP',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '95',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1',
                PRINTTOTAL => '53053',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D9C',
            MAC          => '00:17:A4:93:4D:9C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D9C',
            MAC          => '00:17:A4:93:4D:9C',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447333750',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI934D9C',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG37P',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '41',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '21',
                PRINTTOTAL => '130480',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI917343',
            MAC          => '00:17:08:91:73:43',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI917343',
            MAC          => '00:17:08:91:73:43',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447314D48',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI917343',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG1MH',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '94',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '814',
                PRINTTOTAL => '45077',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l1B220a',
            MAC          => '00:17:A4:93:DF:9C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l1B220a',
            MAC          => '00:17:A4:93:DF:9C',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447314C50',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'l1B220a',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG1LP',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '95',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '12',
                PRINTTOTAL => '11083',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.10.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI824876',
            MAC          => '00:17:08:82:48:76',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI824876',
            MAC          => '00:17:08:82:48:76',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364446305846',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI824876',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DF0XF',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '77',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1',
                PRINTTOTAL => '17204',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.11.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D5B',
            MAC          => '00:17:A4:93:4D:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI934D5B',
            MAC          => '00:17:A4:93:4D:5B',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447333934',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI934D5B',
                MEMORY       => '192',
                SERIAL       => 'CNFW6DG394',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '11',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1',
                PRINTTOTAL => '100796',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.12.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI939CBD',
            MAC          => '00:17:A4:93:A7:56',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI939CBD',
            MAC          => '00:17:A4:93:A7:56',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447314E50',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'NPI939CBD',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG1NP',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '88',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '22',
                PRINTTOTAL => '65087',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.13.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l2427a',
            MAC          => '00:17:A4:94:A6:1F',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'l2427a',
            MAC          => '00:17:A4:94:A6:1F',
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4657364447314D38',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => '0x0115513738313541',
                COMMENTS     => 'HP LaserJet P3005',
                NAME         => 'l2427a',
                MEMORY       => '320',
                SERIAL       => 'CNFW6DG1M8',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK       => '53',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '7',
                PRINTTOTAL => '5388',
            },
        }
    ],
    'hewlett-packard/LaserJet_P3010.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => '00:9C:02:01:3B:81',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => '00:9C:02:01:3B:81',
            MODELSNMP    => 'Printer0402',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'VNBQD3C0BF'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P3010 Series',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
                SERIAL       => 'VNBQD3C0BF',
                NAME         => 'NPI013B81',
                MODEL        => 'HP LaserJet P3010 Series',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '74',
                BLACK      => '15265',
            },
            CARTRIDGES => {
                TONERBLACK => 84
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:9C:02:01:3B:81'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_P3010.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => '00:9C:02:01:3B:81',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => '00:9C:02:01:3B:81',
            MODELSNMP    => 'Printer0402',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'VNBQD3C0BF'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P3010 Series',
                ID           => undef,
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => 'VNBQD3C0BF',
                NAME         => 'NPI013B81',
                MODEL        => 'HP LaserJet P3010 Series',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:9C:02:01:3B:81'
                    }
                ]
            },
            PAGECOUNTERS => {
                BLACK      => '6386',
                RECTOVERSO => '772',
            },
            CARTRIDGES => {
                TONERBLACK => 1
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => '00:21:5A:7E:09:32',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => '00:21:5A:7E:09:32',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                NAME         => 'NPI7E0932',
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => '20040201',
                ID           => undef
            },
            CARTRIDGES => {
                TONERBLACK => 6
            },
            PAGECOUNTERS => {
                RECTOVERSO => '433',
                COLOR      => '0',
                PRINTBLACK => '30965',
                PRINTTOTAL => '30965',
                BLACK      => '30965',
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => '00:21:5A:8D:DF:43',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => '00:21:5A:8D:DF:43',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                COMMENTS     => 'HP LaserJet P2055dn',
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'HP LaserJet P2055dn',
                ID           => undef,
                SERIAL       => '20040201',
                NAME         => 'NPI8DDF43',
                OTHERSERIAL  => '0xFDE8',
            },
            PAGECOUNTERS => {
                BLACK      => '36105',
                PRINTBLACK => '36105',
                PRINTTOTAL => '36105',
                COLOR      => '0',
                RECTOVERSO => '8379'
            },
            CARTRIDGES => {
                TONERBLACK => 88
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => '00:23:7D:83:09:93',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => '00:23:7D:83:09:93',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPI830993',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
            },
            CARTRIDGES => {
                TONERBLACK => 32
            },
            PAGECOUNTERS => {
                RECTOVERSO => '62',
                COLOR      => '0',
                PRINTTOTAL => '3837',
                PRINTBLACK => '3837',
                BLACK      => '3837'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => '00:23:7D:83:E8:D5'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => '00:23:7D:83:E8:D5',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
                NAME         => 'NPI83E8D5',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                RECTOVERSO => '5297',
                PRINTTOTAL => '11057',
                PRINTBLACK => '11057',
                BLACK      => '11057',
            },
            CARTRIDGES => {
                TONERBLACK => 45
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => '00:23:7D:88:6B:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => '00:23:7D:88:6B:5B',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'NPI886B5B',
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => '20040201',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
            },
            CARTRIDGES => {
                TONERBLACK => 56
            },
            PAGECOUNTERS => {
                BLACK      => '19402',
                COLOR      => '0',
                RECTOVERSO => '3761',
                PRINTBLACK => '19402',
                PRINTTOTAL => '19402',
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => '00:23:7D:88:6B:5B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => '00:23:7D:88:6B:5B',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
                MODEL        => 'HP LaserJet P2055dn',
                NAME         => 'NPI886B5B',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
            },
            CARTRIDGES => {
                TONERBLACK => 78
            },
            PAGECOUNTERS => {
                PRINTTOTAL => '17861',
                BLACK      => '17861',
                COLOR      => '0',
                PRINTBLACK => '17861',
                RECTOVERSO => '3192'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => '1C:C1:DE:80:BD:D9',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => '1C:C1:DE:80:BD:D9',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'NPI80BDD9',
                ID           => undef,
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => '20040201',
                MODEL        => 'HP LaserJet P2055dn',
            },
            CARTRIDGES => {
                TONERBLACK => 46
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                PRINTBLACK => '5696',
                RECTOVERSO => '1843',
                PRINTTOTAL => '5696',
                BLACK      => '5696',
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => '1C:C1:DE:CB:39:82',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => '1C:C1:DE:CB:39:82',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                ID           => undef,
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPICB3982',
                MODEL        => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
            },
            CARTRIDGES => {
                TONERBLACK => 38
            },
            PAGECOUNTERS => {
                RECTOVERSO => '6952',
                PRINTBLACK => '26922',
                COLOR      => '0',
                BLACK      => '26922',
                PRINTTOTAL => '26922'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => '3C:4A:92:C0:83:94',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => '3C:4A:92:C0:83:94',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                NAME         => 'NPIC08394',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
            },
            PAGECOUNTERS => {
                BLACK      => '4047',
                RECTOVERSO => '50',
                COLOR      => '0',
                PRINTTOTAL => '4047',
                PRINTBLACK => '4047',
            },
            CARTRIDGES => {
                TONERBLACK => 20
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.10.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => '1C:C1:DE:CB:D8:B1',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => '1C:C1:DE:CB:D8:B1',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPICBD8B1',
                ID           => undef,
            },
            PAGECOUNTERS => {
                PRINTTOTAL => '4944',
                PRINTBLACK => '4944',
                COLOR      => '0',
                RECTOVERSO => '0',
                BLACK      => '4944',
            },
            CARTRIDGES => {
                TONERBLACK => 40
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.11.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => '08:2E:5F:B9:79:A2',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => '08:2E:5F:B9:79:A2',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                ID           => undef,
                SERIAL       => '20040201',
                NAME         => 'NPIB979A2',
                OTHERSERIAL  => '0xFDE8',
                MODEL        => 'HP LaserJet P2055dn',
            },
            PAGECOUNTERS => {
                BLACK      => '4339',
                PRINTBLACK => '4339',
                PRINTTOTAL => '4339',
                COLOR      => '0',
                RECTOVERSO => '498'
            },
            CARTRIDGES => {
                TONERBLACK => 0
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.12.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => '1C:C1:DE:C9:3D:6D'
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => '1C:C1:DE:C9:3D:6D',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP LaserJet P2055dn',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPIC93D6D',
                SERIAL       => '20040201',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '1789',
                COLOR      => '0',
                PRINTBLACK => '89242',
                PRINTTOTAL => '89242',
                BLACK      => '89242'
            },
            CARTRIDGES => {
                TONERBLACK => 68
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.13.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'l1019a',
            MAC          => '00:25:B3:EB:EA:20',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'l1019a',
            MAC          => '00:25:B3:EB:EA:20',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2055dn',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'l1019a',
                MEMORY       => '128',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK       => '74',
            },
            PAGECOUNTERS => {
                BLACK      => '3515',
                PRINTBLACK => '3515',
                COLOR      => '0',
                RECTOVERSO => '0',
                PRINTTOTAL => '3515',
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.14.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIEB8A8F',
            MAC          => '00:25:B3:EB:8A:8F',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIEB8A8F',
            MAC          => '00:25:B3:EB:8A:8F',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2055dn',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'NPIEB8A8F',
                MEMORY       => '128',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK       => '66',
            },
            PAGECOUNTERS => {
                BLACK      => '11344',
                PRINTBLACK => '11344',
                COLOR      => '0',
                RECTOVERSO => '2389',
                PRINTTOTAL => '11344',
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.15.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'l1a220a',
            MAC          => '00:25:B3:EB:7A:C7',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'l1a220a',
            MAC          => '00:25:B3:EB:7A:C7',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2055dn',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'l1a220a',
                MEMORY       => '128',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK       => '2',
            },
            PAGECOUNTERS => {
                BLACK      => '22937',
                PRINTBLACK => '22937',
                COLOR      => '0',
                RECTOVERSO => '6832',
                PRINTTOTAL => '22937',
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.16.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIEB4B44',
            MAC          => '00:25:B3:EB:4B:44',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIEB4B44',
            MAC          => '00:25:B3:EB:4B:44',
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => 'HP LaserJet P2055dn',
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'NPIEB4B44',
                MEMORY       => '128',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK       => '60',
            },
            PAGECOUNTERS => {
                BLACK      => '4878',
                PRINTBLACK => '4878',
                COLOR      => '0',
                RECTOVERSO => '504',
                PRINTTOTAL => '4878',
            },
        }
    ],
    'hewlett-packard/LaserJet_P4015.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => '00:21:5A:8F:EA:2B',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => '00:21:5A:8F:EA:2B',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY417951'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36,CIDATE 04/10/2008',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'LJ30000000000000000000----------',
                SERIAL       => 'CNFY417951',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:8F:EA:2B'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 100,
                MAINTENANCEKIT => 87
            },
            PAGECOUNTERS => {
                RECTOVERSO => '26',
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => '00:21:5A:8D:98:96',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => '00:21:5A:8D:98:96',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY409032'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36,CIDATE 04/10/2008',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI8D9896',
                SERIAL       => 'CNFY409032',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:8D:98:96'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 64,
                MAINTENANCEKIT => 61
            },
            PAGECOUNTERS => {
                RECTOVERSO => '26',
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => '00:1F:29:22:C8:7C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => '00:1F:29:22:C8:7C',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY213364'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.35,CIDATE 09/18/2007',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI22C87C',
                SERIAL       => 'CNFY213364',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.35',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.35',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:1F:29:22:C8:7C'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 34,
                MAINTENANCEKIT => 79
            },
            PAGECOUNTERS => {
                RECTOVERSO => '52',
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => '00:21:5A:97:06:DE',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => '00:21:5A:97:06:DE',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY183496'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.40,CIDATE 02/24/2009',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI9706DE',
                SERIAL       => 'CNFY183496',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.40',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.40',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:21:5A:97:06:DE'
                    }
                ]
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 5,
                TONERBLACK     => 1
            },
            PAGECOUNTERS => {
                RECTOVERSO => '4',
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => '00:25:B3:EA:DB:FB',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => '00:25:B3:EA:DB:FB',
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY349204'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41,CIDATE 06/12/2009',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPIEADBFB',
                SERIAL       => 'CNFY349204',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:25:B3:EA:DB:FB'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK     => 32,
                MAINTENANCEKIT => 0
            },
            PAGECOUNTERS => {
                RECTOVERSO => '2096',
            }
        }
    ],
    'hewlett-packard/LaserJet_CP4520.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => '2C:27:D7:10:DB:2C',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => '2C:27:D7:10:DB:2C',
            MODELSNMP    => 'Printer0639',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'JPCTC8M0LJ',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD145,EEPROM V.38.99,CIDATE 11/26/2010',
                ID           => undef,
                SERIAL       => 'JPCTC8M0LJ',
                OTHERSERIAL  => '0xFDE8',
                MODEL        => 'HP Color LaserJet CP4520 Series',
                NAME         => 'NPI10DB2C',
            },
            PAGECOUNTERS => {
                COLOR      => '5839',
                BLACK      => '8881',
                PRINTCOLOR => '5839',
                PRINTBLACK => '8765',
                PRINTTOTAL => '14610'
            },
            CARTRIDGES => {
                TONERMAGENTA => 44,
                TONERCYAN    => 47,
                TONERYELLOW  => 50
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD145,EEPROM V.38.99',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD145,EEPROM V.38.99',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '2C:27:D7:10:DB:2C'
                    }
                ]
            },
        }
    ],
    'hewlett-packard/LaserJet_CP3525.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => '00:23:7D:85:A5:7D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => '00:23:7D:85:A5:7D',
            MODELSNMP    => 'Printer0388',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCT98DGJY',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.67,CIDATE 06/17/2008',
                ID           => undef,
                SERIAL       => 'CNCT98DGJY',
                NAME         => 'NPI85A57D',
                MODEL        => 'HP Color LaserJet CP3525',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK   => 67,
                TONERYELLOW  => 30,
                TONERCYAN    => 39,
                TONERMAGENTA => 21
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.67',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.67',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:23:7D:85:A5:7D'
                    }
                ]
            },
            PAGECOUNTERS => {
                BLACK      => '7603',
                COLOR      => '9127',
                RECTOVERSO => '0',
            },
        }
    ],
    'hewlett-packard/LaserJet_CP3525.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => 'D4:85:64:3D:AC:2E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => 'D4:85:64:3D:AC:2E',
            MODELSNMP    => 'Printer0388',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCTB9PHWG',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.80,CIDATE 11/03/2009',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'Corinne',
                MODEL        => 'HP Color LaserJet CP3525',
                SERIAL       => 'CNCTB9PHWG',
                ID           => undef
            },
            PAGECOUNTERS => {
                RECTOVERSO => '49',
                BLACK      => '7256',
                COLOR      => '11905',
            },
            CARTRIDGES => {
                TONERYELLOW  => 8,
                TONERCYAN    => 21,
                TONERMAGENTA => 97,
                TONERBLACK   => 53
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.80',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNAME   => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.80',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => 'D4:85:64:3D:AC:2E'
                    }
                ]
            }
        }
    ],
    'hewlett-packard/LaserJet_M1217nfw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet Professional M1217nfw MFP',
            SNMPHOSTNAME => 'l2407a',
            MAC          => '10:60:4B:19:A6:51',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet Professional M1217nfw MFP',
            SNMPHOSTNAME => 'l2407a',
            MAC          => '10:60:4B:19:A6:51',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/l1803a.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI9195E8',
            MAC          => '00:17:08:91:95:E8',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI9195E8',
            MAC          => '00:17:08:91:95:E8',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/l0214a.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'l0214a',
            MAC          => '00:17:08:91:95:E4',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'l0214a',
            MAC          => '00:17:08:91:95:E4',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/l0700a.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI934D66',
            MAC          => '00:17:A4:93:4D:66',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI934D66',
            MAC          => '00:17:A4:93:4D:66',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/l2520a.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI934D6D',
            MAC          => '00:17:A4:93:4D:6D',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI934D6D',
            MAC          => '00:17:A4:93:4D:6D',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
    'hewlett-packard/l1b110a.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI810884',
            MAC          => '00:1B:78:21:EF:DF',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD135,EEPROM V.33.57,CIDATE 10/24/2006',
            SNMPHOSTNAME => 'NPI810884',
            MAC          => '00:1B:78:21:EF:DF',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => 'PRINTER',
                MODEL        => undef,
            },
        }
    ],
);

setPlan(scalar keys %tests);

my $dictionary = getDictionnary();
my $index      = getIndex();

foreach my $test (sort keys %tests) {
    my $snmp  = getSNMP($test);
    my $model = getModel($index, $tests{$test}->[1]->{MODELSNMP});

    my %device0 = getDeviceInfo($snmp);
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp  => $snmp,
        model => $model,
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
