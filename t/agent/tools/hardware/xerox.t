

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
            MODEL        => 'DocuPrint N2125',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            MAC          => '00:00:AA:5C:1C:8C',
            MODEL        => 'DocuPrint N2125',
            MODELSNMP    => 'Printer0687',
            FIRMWARE     => undef,
            SERIAL       => '3510349171',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
                MEMORY       => 32,
                MODEL        => 'DocuPrint N2125',
                ID           => undef,
                SERIAL       => '3510349171'
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
            MODEL        => 'Phaser 5550DT',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => '00:00:AA:D4:A2:FE',
            MODEL        => 'Phaser 5550DT',
            MODELSNMP    => 'Printer0688',
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
                MODEL        => 'Phaser 5550DT',
                NAME         => 'Phaser 5550DT'
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
            MODEL        => 'Phaser 5550DT',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => '00:00:AA:D4:A4:CC',
            MODEL        => 'Phaser 5550DT',
            MODELSNMP    => 'Printer0689',
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
                MODEL        => 'Phaser 5550DT',
                NAME         => 'Phaser 5550DT-1',
                MEMORY       => 0
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
                MODEL        => 'Xerox Phaser 6180MFP-D'
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
            MODEL        => 'WorkCentre 5632 v1',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO007XN',
            MAC          => '00:00:AA:CF:9E:5A',
            MODEL        => 'WorkCentre 5632 v1',
            MODELSNMP    => 'Printer0705',
            FIRMWARE     => undef,
            SERIAL       => '3641509891',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
                MODEL        => 'WorkCentre 5632 v1',
                MEMORY       => 0,
                ID           => undef,
                CONTACT      => 'System Administrator name not set; System Administrator phone number not set; System Administrator location not set; Device Administrator name not set; Device Administrator phone number not set; Device Administrator location not set; company URL not set',
                LOCATION     => 'machine location not set',
                NAME         => 'SO007XN',
                SERIAL       => '3641509891'
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
            MODEL        => 'WorkCentre 5632 v1',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO011XN',
            MAC          => '00:00:AA:CF:84:10',
            MODEL        => 'WorkCentre 5632 v1',
            MODELSNMP    => 'Printer0705',
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
                MODEL        => 'WorkCentre 5632 v1',
                SERIAL       => '3641504792',
                MEMORY       => 0,
                ID           => undef
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
            MODEL        => 'WorkCentre 7435',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => '08:00:37:9B:8F:CA',
            MODEL        => 'WorkCentre 7435',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'WorkCentre 7435',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0211a',
            MAC          => '00:00:AA:C4:27:C4',
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
            SERIAL       => 'FBT261926',
            MODEL        => 'Phaser 8560DN',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MEMORY       => 0,
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                MODEL        => 'Phaser 8560DN',
                SERIAL       => 'FBT261926',
                NAME         => 'c0211a'
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
            MODEL        => 'ColorQube 8570DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox ColorQube 8570DN; System 1.3.8.P, OS 10.62, PS 4.10.0, Eng 23.P1.4.10.0, Net 42.40.09.02.2011, Adobe PostScript 3016.101 (16), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0500a',
            MAC          => '9C:93:4E:02:92:55',
            MODEL        => 'ColorQube 8570DN',
            MODELSNMP    => 'Printer0670',
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'ColorQube 8570DN',
                NAME         => 'c0500a'
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c1309a',
            MAC          => '00:00:AA:D2:C6:82',
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
            SERIAL       => 'FBT340010',
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
                MODEL        => 'Phaser 8560DN',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1500a',
            MAC          => '00:00:AA:A7:E4:D3',
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0314',
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
                MODEL        => 'Phaser 8560DN',
                SERIAL       => 'FBT133984',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c1715a',
            MAC          => '00:00:AA:A7:E5:B6',
            FIRMWARE     => undef,
            SERIAL       => 'FBT133868',
            MODEL        => 'Phaser 8560DN',
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
                MODEL        => 'Phaser 8560DN',
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
                MEMORY       => 0
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c0400a',
            MAC          => '00:00:AA:C4:27:29',
            SERIAL       => 'FBT261925',
            FIRMWARE     => undef,
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0265',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'c0400a',
                MEMORY       => 0,
                MODEL        => 'Phaser 8560DN',
                SERIAL       => 'FBT261925'
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
            SNMPHOSTNAME => 'Phaser 8560DN-2',
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'Phaser 8560DN-2',
            MAC          => '00:00:AA:A8:12:CF',
            FIRMWARE     => undef,
            SERIAL       => 'FBT133950',
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0314'
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                NAME         => 'Phaser 8560DN-2',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
                MODEL        => 'Phaser 8560DN',
                SERIAL       => 'FBT133950',
                MEMORY       => 0,
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
                TYPE         => 'PRINTER'
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME => 'c2206a',
            FIRMWARE     => undef,
            SERIAL       => 'FBT163981',
            MAC          => '00:00:AA:AB:95:BE',
            MODEL        => 'Phaser 8560DN',
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
                MODEL        => 'Phaser 8560DN',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c2410a',
            MAC          => '00:00:AA:C4:27:0F',
            FIRMWARE     => undef,
            SERIAL       => 'FBT261951',
            MODEL        => 'Phaser 8560DN',
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
                MODEL        => 'Phaser 8560DN',
                MEMORY       => 0
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
                MODEL        => 'Xerox Phaser 8550DP;PS3.11.0,Net24.38.04.28,Eng18.P1.3.11.0'
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.86, PS 4.10.0, Eng 22.L0.4.10.0, Net 37.58.08.31.2009, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3003a',
            MAC          => '00:00:AA:C4:28:2C',
            MODEL        => 'Phaser 8560DN',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'Phaser 8560DN',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => 'PRINTER',
            DESCRIPTION   => 'Xerox Phaser 8560DN; OS 7.86, PS 4.1.0, Eng 22.L0.4.1.0, Net 31.92.12.14.2006',
            SNMPHOSTNAME  => 'c3111a',
            MAC           => '00:00:AA:AB:96:82',
            FIRMWARE      => undef,
            MODEL         => 'Phaser 8560DN',
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
                MODEL        => 'Phaser 8560DN',
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'c3312a',
            SERIAL       => 'FBT163983',
            MAC          => '00:00:AA:AB:92:93',
            MODEL        => 'Phaser 8560DN',
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
                MODEL        => 'Phaser 8560DN',
                TYPE         => 'PRINTER',
                MANUFACTURER => 'Xerox'
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
            MODEL        => 'Phaser 8560DT',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DT; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'ciT400a',
            MAC          => '00:00:AA:D2:C5:EB',
            MODEL        => 'Phaser 8560DT',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'Phaser 8560DT',
                ID           => undef
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT510a',
            MAC          => '00:00:AA:D7:5B:A0',
            SERIAL       => 'FBT261947',
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0265',
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                MODEL        => 'Phaser 8560DN',
                MEMORY       => 0,
                SERIAL       => 'FBT261947',
                NAME         => 'cIT510a',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                ID           => undef
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'cIT524a',
            MAC          => '00:00:AA:C4:26:B0',
            SERIAL       => 'FBT261949',
            FIRMWARE     => undef,
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0265',
        },
        {
            INFO => {
                SERIAL       => 'FBT261949',
                TYPE         => 'PRINTER',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                NAME         => 'cIT524a',
                MODEL        => 'Phaser 8560DN',
                MANUFACTURER => 'Xerox',
                ID           => undef,
                MEMORY       => 0
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
            MODEL        => 'Phaser 8560DN',
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
            SNMPHOSTNAME => 'Phaser 8560DN',
            MAC          => '00:00:AA:C4:26:61',
            SERIAL       => 'FBT261946',
            FIRMWARE     => undef,
            MODEL        => 'Phaser 8560DN',
            MODELSNMP    => 'Printer0265',
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => 'Phaser 8560DN',
                COMMENTS     => 'Xerox Phaser 8560DN; OS 9.82, PS 4.7.0, Eng 22.L0.4.7.0, Net 37.54.03.02.2008, Adobe PostScript 3016.101 (11), PCL 5c Version 5.0',
                SERIAL       => 'FBT261946',
                MEMORY       => 0,
                NAME         => 'Phaser 8560DN'
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

    my %device0 = getDeviceInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply(\%device0, $tests{$test}->[0], "$test: base stage");

    my %device1 = getDeviceInfo(
        snmp       => $snmp,
        dictionary => $dictionary,
        datadir    => './share'
    );
    cmp_deeply(\%device1, $tests{$test}->[1], "$test: base + dictionnary stage");

    my $device3 = getDeviceFullInfo(
        snmp    => $snmp,
        model   => $model,
        datadir => './share'
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
use Data::Dumper;
