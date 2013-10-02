#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'xerox/DocuPrint_N2125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            MAC          => '00:00:AA:5C:1C:8C',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            MAC          => '00:00:AA:5C:1C:8C',
            MODELSNMP    => 'Printer0687',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '3510349171',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
                MEMORY       => 32,
                MODEL        => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
                ID           => undef,
                SERIAL       => '3510349171',
                UPTIME       => '(16986889) 1 day, 23:11:08.89'
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'Xerox DocuPrint N21 Ethernet Interface',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:00:AA:5C:1C:8C'
                    }
                ]
            },
        }
    ],
    'xerox/Phaser_5550DT.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => '00:00:AA:D4:A2:FE',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => '00:00:AA:D4:A2:FE',
            MODELSNMP    => 'Printer0688',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'KNB015751',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
                SERIAL       => 'KNB015751',
                MEMORY       => 0,
                ID           => undef,
                MODEL        => 'Xerox Phaser 5550DT;OS8.2,PS5.1.0,Eng11.58.00,Net40.46.04.03',
                NAME         => 'Phaser 5550DT',
                UPTIME       => '(7088810) 19:41:28.10'
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)'
                    },
                    {
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    }
                ]
            },
        }
    ],
    'xerox/Phaser_5550DT.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => '00:00:AA:D4:A4:CC',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => '00:00:AA:D4:A4:CC',
            MODELSNMP    => 'Printer0689',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'KNB015753',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
                ID           => undef,
                SERIAL       => 'KNB015753',
                MODEL        => 'Xerox Phaser 5550DT;OS8.2,PS5.1.0,Eng11.58.00,Net40.46.04.03',
                NAME         => 'Phaser 5550DT-1',
                MEMORY       => 0,
                UPTIME       => '(52327401) 6 days, 1:21:14.01'
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
                    }
                ]
            },
        }
    ],
    'xerox/Phaser_6180MFP.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME => 'Phaser 6180MFP-D-E360D7',
            MAC          => '00:00:AA:E3:60:D7',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME => 'Phaser 6180MFP-D-E360D7',
            MAC          => '00:00:AA:E3:60:D7',
            MODELSNMP    => 'Printer0370',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'GPX259705',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
                MEMORY       => 0,
                SERIAL       => 'GPX259705',
                ID           => undef,
                NAME         => 'Phaser 6180MFP-D-E360D7',
                MODEL        => 'Xerox Phaser 6180MFP-D',
                UPTIME       => '(119016820) 13 days, 18:36:08.20'
            },
            CARTRIDGES => {
                TONERMAGENTA => 25,
                TONERCYAN    => 25,
                TONERBLACK   => 5,
                TONERYELLOW  => 40
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '172.16.3.61',
                        IFNUMBER => '1',
                        MAC      => '00:00:AA:E3:60:D7',
                        IFNAME   => 'XEROX Ethernet Interface Controller, 10/100 Mbps, RJ45, v1.0, 100Mbps full duplex'
                    }
                ]
            },
            PAGECOUNTERS => {
                FAXTOTAL   => 'Faxed Impressions',
                BLACK      => 'Black Impressions ',
                COPYBLACK  => 'Black Copied Impressions',
            }
        }
    ],
    'xerox/WorkCentre_5632.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO007XN',
            MAC          => '00:00:AA:CF:9E:5A',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO007XN',
            MAC          => '00:00:AA:CF:9E:5A',
            MODELSNMP    => 'Printer0705',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '3641509891',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
                MODEL        => 'Xerox WorkCentre 5632 v1 Multifunction System',
                MEMORY       => 0,
                ID           => undef,
                CONTACT      => 'System Administrator name not set; System Administrator phone number not set; System Administrator location not set; Device Administrator name not set; Device Administrator phone number not set; Device Administrator location not set; company URL not set',
                LOCATION     => 'machine location not set',
                NAME         => 'SO007XN',
                SERIAL       => '3641509891',
                UPTIME       => '(36879516) 4 days, 6:26:35.16'
            },
            CARTRIDGES => {
                TONERBLACK => 45
            },
            PORTS => {
                PORT => [
                    {
                        MAC      => '00:00:AA:CF:9E:5A',
                        IFNUMBER => '1',
                        IFTYPE   => '6',
                        IFNAME   => 'Xerox Embedded Ethernet Controller, 10/100/1000 Mbps, v1.0, RJ45, 100 Mbps full duplex',
                        IP       => '129.181.20.136'
                    },
                    {
                        MAC      => '00:00:00:00:00:00',
                        IFNUMBER => '2',
                        IFTYPE   => '24',
                        IFNAME   => 'Xerox internal TCP Software Loopback Interface, v2.0',
                        IP       => '127.0.0.1'
                    },
                ]
            }
        }
    ],
    'xerox/WorkCentre_5632.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO011XN',
            MAC          => '00:00:AA:CF:84:10',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO011XN',
            MAC          => '00:00:AA:CF:84:10',
            MODELSNMP    => 'Printer0705',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '3641504792',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
                LOCATION     => 'machine location not set',
                NAME         => 'SO011XN',
                CONTACT      => 'System Administrator name not set; System Administrator phone number not set; System Administrator location not set; Device Administrator name not set; Device Administrator phone number not set; Device Administrator location not set; company URL not set',
                MODEL        => 'Xerox WorkCentre 5632 v1 Multifunction System',
                SERIAL       => '3641504792',
                MEMORY       => 0,
                ID           => undef,
                UPTIME       => '(717880872) 83 days, 2:06:48.72'
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'Xerox Embedded Ethernet Controller, 10/100/1000 Mbps, v1.0, RJ45, 100 Mbps full duplex',
                        MAC      => '00:00:AA:CF:84:10',
                        IFTYPE   => '6',
                        IP       => '129.181.20.135'
                    },
                    {
                        IFTYPE   => '24',
                        MAC      => '00:00:00:00:00:00',
                        IFNAME   => 'Xerox internal TCP Software Loopback Interface, v2.0',
                        IFNUMBER => '2',
                        IP       => '127.0.0.1'
                    },
                ]
            },
            CARTRIDGES => {
                TONERBLACK => 90
            },
        }
    ],
    'xerox/WorkCentre_7125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME => 'XEROX WorkCentre 7125',
            MAC          => '08:00:37:B9:16:5D',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => 'PRINTER',
            DESCRIPTION   => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME  => 'XEROX WorkCentre 7125',
            MAC           => '08:00:37:B9:16:5D',
            MODELSNMP     => 'Printer0690',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3325295030',
        },
        {
            INFO         => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
                SERIAL       => '3325295030',
                ID           => undef,
                MODEL        => undef,
                MEMORY       => 2,
                NAME         => 'XEROX WorkCentre 7125',
                UPTIME       => '(9495100) 1 day, 2:22:31.00'
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => 'iso88023Csmacd(7)',
                        IFNUMBER => '1',
                        IFNAME   => 'Xerox Embedded Ethernet Controller, 10/100 Mbps, v1.0, RJ45, auto',
                        MAC      => '08:00:37:B9:16:5D'
                    },
                    {
                        IFTYPE   => 'usb(160)',
                        IFNAME   => 'Xerox USB-1 - Network Interface',
                        IFNUMBER => '2',
                    },
                    {
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNUMBER => '3',
                        IFNAME => 'Xerox Internal TCP Software Loopback Interface',
                    }
                ]
            },
            PAGECOUNTERS => {
                COLOR      => '6964',
                PRINTBLACK => '3251',
                PRINTTOTAL => '13755',
                BLACK      => '4086',
                COPYCOLOR  => '1394',
                PRINTCOLOR => '6964',
                COPYBLACK  => '1311'
            },
            CARTRIDGES => {
                TONERMAGENTA => 58,
                TONERBLACK => 31
            }
        }
    ],
    'xerox/WorkCentre_7435.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => '08:00:37:9B:8F:CA',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => '08:00:37:9B:8F:CA',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
                COMMENTS     => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
                NAME         => 'WorkCentre 7435',
            },
        }
    ],
    'xerox/Phaser_8560DN.4.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0211a',
            MAC          => '00:00:AA:C4:27:C4',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0211a',
            MAC          => '00:00:AA:C4:27:C4',
            MODEL        => undef,
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
            SERIAL       => 'FBT261926'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MEMORY       => 0,
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                SERIAL       => 'FBT261926',
                NAME         => 'c0211a',
                UPTIME       => '(9827360) 1 day, 3:17:53.60'
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 22,
                TONERMAGENTA   => 100,
                TONERYELLOW    => 100,
                WASTETONER     => 100,
                TONERCYAN      => 100,
                TONERBLACK     => 100
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        MAC      => '00:00:AA:C4:27:C4'
                    },
                    {
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.18',
                        MAC      => '00:00:AA:C4:27:C4',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '2'
                    }
                ]
            }
        }
    ],
    'xerox/ColorQube_8570DN.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox ColorQube 8570DN; System 1.3.8.P, OS 10.62, PS 4.10.0, Eng 23.P1.4.10.0, Net 42.40.09.02.2011, Adobe PostScript 3016.101 (16), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0500a',
            MAC          => '9C:93:4E:02:92:55',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox ColorQube 8570DN; System 1.3.8.P, OS 10.62, PS 4.10.0, Eng 23.P1.4.10.0, Net 42.40.09.02.2011, Adobe PostScript 3016.101 (16), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0500a',
            MAC          => '9C:93:4E:02:92:55',
            MODEL        => undef,
            MODELSNMP    => 'Printer0670',
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'Xerox ColorQube 8570DN;OS10.62,Eng23.P1.4.10.0,Net42.40.09.02',
                NAME         => 'c0500a',
                UPTIME       => '(457023) 1:16:10.23',
                COMMENTS     => 'Xerox ColorQube 8570DN; System 1.3.8.P, OS 10.62, PS 4.10.0, Eng 23.P1.4.10.0, Net 42.40.09.02.2011, Adobe PostScript 3016.101 (16), PCL 5c Version 5.0',
                MEMORY       => 0,
            },
            PAGECOUNTERS => {
                TOTAL => '401'
            },
        }
    ],
    'xerox/Phaser_8560DN.5.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c1309a',
            MAC          => '00:00:AA:D2:C6:82',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c1309a',
            MAC          => '00:00:AA:D2:C6:82',
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
            SERIAL       => 'FBT340010',
            MODEL        => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                SERIAL       => 'FBT340010',
                MEMORY       => 0,
                NAME         => 'c1309a',
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                UPTIME       => '(184090216) 21 days, 7:21:42.16'
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '127.0.0.1',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)',
                        MAC      => '00:00:AA:D2:C6:82'
                    },
                    {
                        IP       => '128.93.22.37',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:00:AA:D2:C6:82'
                    }
                ]
            },
            CARTRIDGES => {
                WASTETONER     => 100,
                MAINTENANCEKIT => 14,
                TONERBLACK     => 100,
                TONERCYAN      => 100,
                TONERYELLOW    => 100,
                TONERMAGENTA   => 100
            },
        }
    ],
    'xerox/Phaser_8560DN.6.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1500a',
            MAC          => '00:00:AA:A7:E4:D3',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1500a',
            MAC          => '00:00:AA:A7:E4:D3',
            MODELSNMP    => 'Printer0314',
            MODEL        => undef,
            SERIAL       => 'FBT133984',
            FIRMWARE     => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                NAME         => 'c1500a',
                MEMORY       => 0,
                MODEL        => undef,
                SERIAL       => 'FBT133984',
                UPTIME       => '(745557553) 86 days, 6:59:35.53'
            },
            CARTRIDGES => {
                TONERCYAN      => 100,
                WASTETONER     => 100,
                TONERBLACK     => 100,
                TONERYELLOW    => 100,
                TONERMAGENTA   => 100,
                MAINTENANCEKIT => 69
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            PORTS => {
                PORT => [
                    {
                        MAC      => '00:00:AA:A7:E4:D3',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.65',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1'
                    },
                    {
                        IFNUMBER => '2',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '127.0.0.1',
                        IFTYPE   => 'softwareLoopback(24)',
                        MAC      => '00:00:AA:A7:E4:D3'
                    }
                ]
            },
        }
    ],
    'xerox/Phaser_8560DN.7.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1715a',
            MAC          => '00:00:AA:A7:E5:B6',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1715a',
            MAC          => '00:00:AA:A7:E5:B6',
            FIRMWARE     => undef,
            MODEL        => undef,
            SERIAL       => 'FBT133868',
            MODELSNMP    => 'Printer0314'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                SERIAL       => 'FBT133868',
                MEMORY       => 0,
                NAME         => 'c1715a',
                MODEL        => undef,
                UPTIME       => '(745560805) 86 days, 7:00:08.05'
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            CARTRIDGES => {
                TONERBLACK => 100,
                WASTETONER => 100,
                TONERMAGENTA => 100,
                TONERCYAN => 100,
                TONERYELLOW => 100,
                MAINTENANCEKIT => 90
            },
            PORTS => {
                PORT => [
                    {
                        IP       => '128.93.22.17',
                        IFNUMBER => '1',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:00:AA:A7:E5:B6'
                    },
                    {
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'softwareLoopback(24)',
                        MAC      => '00:00:AA:A7:E5:B6',
                        IP       => '127.0.0.1',
                        IFNUMBER => '2'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DP.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'c1A110a-1',
            MAC          => '00:00:AA:95:17:A7',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'c1A110a-1',
            MAC          => '00:00:AA:95:17:A7',
            FIRMWARE     => undef,
            SERIAL       => 'WYP050086',
            MODEL        => undef,
            MODELSNMP    => 'Printer0451'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
                NAME         => 'c1A110a-1',
                MODEL        => 'Xerox Phaser 8550DP;PS3.11.0,Net24.38.04.28,Eng18.P1.3.11.0',
                SERIAL       => 'WYP050086',
                MEMORY       => 0,
                UPTIME       => '(339691530) 39 days, 7:35:15.30'
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.95',
                        MAC      => '00:00:AA:95:17:A7',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    },
                    {
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '2',
                        MAC      => '00:00:AA:95:17:A7'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DN.8.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0400a',
            MAC          => '00:00:AA:C4:27:29',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0400a',
            MAC          => '00:00:AA:C4:27:29',
            SERIAL       => 'FBT261925',
            FIRMWARE     => undef,
            MODELSNMP    => 'Printer0265',
            MODEL        => undef
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'c0400a',
                MEMORY       => 0,
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                SERIAL       => 'FBT261925',
                UPTIME       => '(537900356) 62 days, 6:10:03.56'
            },
            PORTS => {
                PORT => [
                    {
                        IP => '127.0.0.1',
                        IFTYPE => 'softwareLoopback(24)',
                        IFNAME => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, half duplex',
                        IFNUMBER => '1',
                        MAC => '00:00:AA:C4:27:29'
                    },
                    {
                        IFNAME => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, half duplex',
                        MAC => '00:00:AA:C4:27:29',
                        IFNUMBER => '2',
                        IFTYPE => 'ethernetCsmacd(6)',
                        IP => '128.93.22.114'
                    }
                ]
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 20,
                TONERCYAN      => 100,
                TONERYELLOW    => 100,
                TONERMAGENTA   => 100,
                WASTETONER     => 100,
                TONERBLACK     => 100
            }
        }
    ],
    'xerox/Phaser_8560DN.9.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            MAC          => '00:00:AA:A8:12:CF',
            SNMPHOSTNAME => 'Phaser 8560DN-2'
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            MODEL        => undef,
            SNMPHOSTNAME => 'Phaser 8560DN-2',
            MAC          => '00:00:AA:A8:12:CF',
            FIRMWARE     => undef,
            SERIAL       => 'FBT133950',
            MODELSNMP    => 'Printer0314'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                NAME         => 'Phaser 8560DN-2',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                MODEL        => undef,
                SERIAL       => 'FBT133950',
                MEMORY       => 0,
                UPTIME       => '(53965840) 6 days, 5:54:18.40'
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            CARTRIDGES => {
                TONERBLACK     => 100,
                TONERCYAN      => 100,
                WASTETONER     => 100,
                MAINTENANCEKIT => 89,
                TONERMAGENTA   => 100,
                TONERYELLOW    => 100
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        MAC      => '00:00:AA:A8:12:CF',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.150',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    },
                    {
                        IP       => '127.0.0.1',
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNUMBER => '2',
                        MAC      => '00:00:AA:A8:12:CF',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DP.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'c2009a',
            MAC          => '00:00:AA:95:16:50',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'c2009a',
            MAC          => '00:00:AA:95:16:50',
            MODELSNMP    => 'Printer0451',
            SERIAL       => 'WYP050250',
            FIRMWARE     => undef,
            MODEL        => undef,
        },
        {
            INFO => {
                COMMENTS     => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
                MODEL        => 'Xerox Phaser 8550DP;PS3.11.0,Net24.38.04.28,Eng18.P1.3.11.0',
                SERIAL       => 'WYP050250',
                NAME         => 'c2009a',
                MEMORY       => 0,
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                UPTIME       => '(284944040) 32 days, 23:30:40.40'
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1',
                        IP       => '128.93.22.40',
                        MAC      => '00:00:AA:95:16:50',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    },
                    {
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        MAC      => '00:00:AA:95:16:50',
                        IFNUMBER => '2',
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DN.10.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            MAC          => '00:00:AA:AB:95:BE',
            SNMPHOSTNAME => 'c2206a',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c2206a',
            FIRMWARE     => undef,
            SERIAL       => 'FBT163981',
            MODEL        => undef,
            MAC          => '00:00:AA:AB:95:BE',
            MODELSNMP    => 'Printer0314'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                SERIAL       => 'FBT163981',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                NAME         => 'c2206a',
                MEMORY       => 0,
                MODEL        => undef,
                UPTIME       => '(504016756) 58 days, 8:02:47.56',
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IP       => '128.93.22.82',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1',
                        MAC      => '00:00:AA:AB:95:BE'
                    },
                    {
                        IFNUMBER => '2',
                        MAC      => '00:00:AA:AB:95:BE',
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '127.0.0.1'
                    }
                ]
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            CARTRIDGES => {
                WASTETONER     => 100,
                TONERBLACK     => 100,
                TONERCYAN      => 100,
                TONERMAGENTA   => 100,
                MAINTENANCEKIT => 14,
                TONERYELLOW    => 100
            },
        }
    ],
    'xerox/Phaser_8560DN.11.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c2410a',
            MAC          => '00:00:AA:C4:27:0F',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c2410a',
            MAC          => '00:00:AA:C4:27:0F',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FBT261951',
            MODELSNMP    => 'Printer0265'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'c2410a',
                SERIAL       => 'FBT261951',
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                MEMORY       => 0,
                UPTIME       => '(72059111) 8 days, 8:09:51.11',
            },
            PORTS => {
                PORT => [
                    {
                        MAC      => '00:00:AA:C4:27:0F',
                        IP       => '127.0.0.1',
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1'
                    },
                    {
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '2',
                        IP       => '128.93.22.60',
                        MAC      => '00:00:AA:C4:27:0F'
                    }
                ]
            },
            CARTRIDGES => {
                WASTETONER     => 100,
                TONERCYAN      => 100,
                MAINTENANCEKIT => 99,
                TONERMAGENTA   => 100,
                TONERYELLOW    => 100,
                TONERBLACK     => 100
            }
        }
    ],
    'xerox/Phaser_8560DP.3.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'Phaser 8550DP',
            MAC          => '00:00:AA:95:17:A8'
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            MODEL        => undef,
            MODELSNMP    => 'Printer0451',
            SNMPHOSTNAME => 'Phaser 8550DP',
            SERIAL       => 'WYP050085',
            FIRMWARE     => undef,
            MAC          => '00:00:AA:95:17:A8'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
                NAME         => 'Phaser 8550DP',
                MEMORY       => 0,
                SERIAL       => 'WYP050085',
                MODEL        => 'Xerox Phaser 8550DP;PS3.11.0,Net24.38.04.28,Eng18.P1.3.11.0',
                UPTIME       => '(543157724) 62 days, 20:46:17.24',
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.54',
                        MAC      => '00:00:AA:95:17:A8',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNUMBER => '1'
                    },
                    {
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        MAC      => '00:00:AA:95:17:A8',
                        IFNUMBER => '2'
                    }
                ]
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
        }
    ],
    'xerox/Phaser_8560DP.4.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            SNMPHOSTNAME => 'c2700a',
            MAC          => '00:00:AA:95:15:B8'
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
            MODEL        => undef,
            SERIAL       => 'WYP050251',
            SNMPHOSTNAME => 'c2700a',
            MODELSNMP    => 'Printer0451',
            MAC          => '00:00:AA:95:15:B8',
            FIRMWARE     => undef
        },
        {
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8550DP;PS 3.11.0,Net 24.38.04.28.2005,Eng 18.P1.3.11.0,OS 4.278',
                MODEL        => 'Xerox Phaser 8550DP;PS3.11.0,Net24.38.04.28,Eng18.P1.3.11.0',
                MEMORY       => 0,
                NAME         => 'c2700a',
                SERIAL       => 'WYP050251',
                UPTIME       => '(543164034) 62 days, 20:47:20.34',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        MAC      => '00:00:AA:95:15:B8',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.207'
                    },
                    {
                        MAC      => '00:00:AA:95:15:B8',
                        IFNUMBER => '2',
                        IFNAME   => 'Xerox Phaser 8550 Ethernet Interface, 10/100 Mbps, v(3.11.0/24.38.04.28.2005/18.P1.3.11.0/4.278), RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DN.12.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.86, PS 4.10.0, Eng 22.L0.4.10.0, Net 37.58.08.31.2009, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3003a',
            MAC          => '00:00:AA:C4:28:2C',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.86, PS 4.10.0, Eng 22.L0.4.10.0, Net 37.58.08.31.2009, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3003a',
            MAC          => '00:00:AA:C4:28:2C',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => undef,
                UPTIME       => '(80535700) 9 days, 7:42:37.00',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.86, PS 4.10.0, Eng 22.L0.4.10.0, Net 37.58.08.31.2009, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'c3003a',
                MEMORY       => 0,
            }
        }
    ],
    'xerox/Phaser_8560DN.13.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c3111a',
            MAC          => '00:00:AA:AB:96:82',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => 'PRINTER',
            DESCRIPTION   => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME  => 'c3111a',
            MAC           => '00:00:AA:AB:96:82',
            FIRMWARE      => undef,
            MODEL         => undef,
            MODELSNMP     => 'Printer0314',
            SERIAL        => 'FBT164018',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                ID           => undef,
                SERIAL       => 'FBT164018',
                NAME         => 'c3111a',
                MEMORY       => 0,
                MODEL        => undef,
                UPTIME       => '(182596303) 21 days, 3:12:43.03'
            },
            PAGECOUNTERS => {
                BLACK => 'Black Impressions'
            },
            CARTRIDGES => {
                WASTETONER     => 100,
                TONERBLACK     => 100,
                MAINTENANCEKIT => 99,
                TONERMAGENTA   => 100,
                TONERYELLOW    => 100,
                TONERCYAN      => 100
            },
            PORTS => {
                PORT => [
                    {
                        MAC      => '00:00:AA:AB:96:82',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.94',
                        IFNUMBER => '1',
                        IFTYPE   => 'ethernetCsmacd(6)'
                    },
                    {
                        IFTYPE   => 'softwareLoopback(24)',
                        MAC      => '00:00:AA:AB:96:82',
                        IFNUMBER => '2',
                        IP       => '127.0.0.1',
                        IFNAME   => 'Xerox Phaser 8560 Ethernet Interface, 10/100 Mbps, v31.92.12.14.2006, RJ-45, Ethernet, 100 Mbps, full duplex'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DN.14.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3312a',
            MAC          => '00:00:AA:AB:92:93',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3312a',
            SERIAL       => 'FBT163983',
            MAC          => '00:00:AA:AB:92:93',
            MODEL        => undef,
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
        },
        {
            INFO => {
                NAME         => 'c3312a',
                MEMORY       => 0,
                SERIAL       => 'FBT163983',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                ID           => undef,
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Xerox',
                UPTIME       => '(745216738) 86 days, 6:02:47.38'
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        MAC      => '00:00:AA:AB:92:93',
                        IP       => '127.0.0.1'
                    },
                    {
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNUMBER => '2',
                        IP       => '128.93.22.218',
                        MAC      => '00:00:AA:AB:92:93'
                    }
                ]
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 28,
                TONERYELLOW    => 100,
                TONERCYAN      => 100,
                TONERMAGENTA   => 100,
                TONERBLACK     => 100,
                WASTETONER     => 100
            },
        }
    ],
    'xerox/Phaser_8560DT.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DT; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'ciT400a',
            MAC          => '00:00:AA:D2:C5:EB',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DT; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'ciT400a',
            MAC          => '00:00:AA:D2:C5:EB',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => undef,
                ID           => undef,
                UPTIME       => '(132190381) 15 days, 7:11:43.81',
                COMMENTS     => 'Xerox Phaser 8560DT; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'ciT400a',
                MEMORY       => 0,
            }
        }
    ],
    'xerox/Phaser_8560DN.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT510a',
            MAC          => '00:00:AA:D7:5B:A0',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT510a',
            MAC          => '00:00:AA:D7:5B:A0',
            SERIAL       => 'FBT261947',
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
            MODEL        => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                MEMORY       => 0,
                SERIAL       => 'FBT261947',
                NAME         => 'cIT510a',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                ID           => undef,
                UPTIME       => '(8607383) 23:54:33.83'
            },
            CARTRIDGES => {
                WASTETONER     => 100,
                MAINTENANCEKIT => 71,
                TONERMAGENTA   => 100,
                TONERBLACK     => 100,
                TONERYELLOW    => 100,
                TONERCYAN      => 100
            },
            PORTS => {
                PORT => [
                    {
                        MAC      => '00:00:AA:D7:5B:A0',
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '1'
                    },
                    {
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:00:AA:D7:5B:A0',
                        IP       => '128.93.22.227'
                    }
                ]
            }
        }
    ],
    'xerox/Phaser_8560DN.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT524a',
            MAC          => '00:00:AA:C4:26:B0',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT524a',
            MAC          => '00:00:AA:C4:26:B0',
            MODEL        => undef,
            SERIAL       => 'FBT261949',
            FIRMWARE     => undef,
            MODELSNMP    => 'Printer0265',
        },
        {
            INFO => {
                SERIAL       => 'FBT261949',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'cIT524a',
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                MANUFACTURER => 'Xerox',
                ID           => undef,
                MEMORY       => 0,
                UPTIME       => '(262695935) 30 days, 9:42:39.35'
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => 'softwareLoopback(24)',
                        IFNUMBER => '1',
                        IP       => '127.0.0.1',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        MAC      => '00:00:AA:C4:26:B0'
                    },
                    {
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IP       => '128.93.22.228',
                        MAC      => '00:00:AA:C4:26:B0',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNUMBER => '2'
                    }
                ]
            },
            CARTRIDGES => {
                TONERCYAN      => 100,
                TONERMAGENTA   => 100,
                MAINTENANCEKIT => 68,
                TONERBLACK     => 100,
                WASTETONER     => 100,
                TONERYELLOW    => 100
            }
        }
    ],
    'xerox/Phaser_8560DN.3.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'Phaser 8560DN',
            MAC          => '00:00:AA:C4:26:61',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'Phaser 8560DN',
            MAC          => '00:00:AA:C4:26:61',
            MODEL        => undef,
            SERIAL       => 'FBT261946',
            FIRMWARE     => undef,
            MODELSNMP    => 'Printer0265',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'Xerox Phaser 8560DN;OS9.82,PS4.7.0,Eng22.L0.4.7.0,Net37.54.03.02',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                SERIAL       => 'FBT261946',
                MEMORY       => 0,
                NAME         => 'Phaser 8560DN',
                UPTIME       => '(1056921) 2:56:09.21'
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex',
                        IFTYPE   => 'softwareLoopback(24)',
                        IP       => '127.0.0.1',
                        MAC      => '00:00:AA:C4:26:61',
                        IFNUMBER => '1'
                    },
                    {
                        IFNUMBER => '2',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:00:AA:C4:26:61',
                        IP       => '128.93.22.229',
                        IFNAME   => 'Xerox Phaser 8560DN Ethernet Interface, 10/100 Mbps, v37.54.03.02.2008, RJ-45, Ethernet, 100 Mbps, full duplex'
                    }
                ]
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 71,
                TONERMAGENTA   => 100,
                TONERYELLOW    => 100,
                WASTETONER     => 100,
                TONERBLACK     => 100,
                TONERCYAN      => 100
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
use Data::Dumper;
