#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'xerox/DocuPrint_N2125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME => '',
            MAC          => undef,
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
                NAME         => undef,
                MODEL        => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
                LOCATION     => undef,
                CONTACT      => undef,
                ID           => undef,
                SERIAL       => '3510349171'
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME   => 'Xerox DocuPrint N21 Ethernet Interface',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => ''
                    }
                ]
            },
            PAGECOUNTERS => {
                PRINTBLACK => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                RECTOVERSO => undef,
                COLOR      => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => undef
            },
        }
    ],
    'xerox/Phaser_5550DT.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => undef,
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
                LOCATION     => undef,
                CONTACT      => undef,
                ID           => undef,
                MODEL        => 'Xerox Phaser 5550DT;OS8.2,PS5.1.0,Eng11.58.00,Net40.46.04.03',
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
            PAGECOUNTERS => {
                COLOR      => undef,
                RECTOVERSO => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                TOTAL      => undef,
                COPYTOTAL  => undef,
                BLACK      => undef,
                PRINTBLACK => undef
            }
        }
    ],
    'xerox/Phaser_5550DT.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => undef,
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
                LOCATION     => undef,
                SERIAL       => 'KNB015753',
                MODEL        => 'Xerox Phaser 5550DT;OS8.2,PS5.1.0,Eng11.58.00,Net40.46.04.03',
                CONTACT      => undef,
                NAME         => 'Phaser 5550DT-1',
                MEMORY       => 0
            },
            PAGECOUNTERS => {
                COPYCOLOR  => undef,
                PRINTTOTAL => undef,
                PRINTCOLOR => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                BLACK      => undef,
                COPYTOTAL  => undef
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
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME => 'Phaser 6180MFP-D-E360D7',
            MAC          => undef,
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
                LOCATION     => undef,
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
                        MAC      => '',
                        IFNAME   => 'XEROX Ethernet Interface Controller, 10/100 Mbps, RJ45, v1.0, 100Mbps full duplex'
                    }
                ]
            },
            PAGECOUNTERS => {
                FAXTOTAL   => 'Faxed Impressions',
                SCANNED    => undef,
                PRINTCOLOR => undef,
                PRINTBLACK => undef,
                BLACK      => 'Black Impressions ',
                COPYTOTAL  => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                RECTOVERSO => undef,
                COPYBLACK  => 'Black Copied Impressions',
                COPYCOLOR  => undef,
                COLOR      => undef
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
                SERIAL       => '3641509891'
            },
            PAGECOUNTERS => {
                TOTAL      => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                SCANNED    => undef,
                RECTOVERSO => undef,
                COLOR      => undef,
                COPYTOTAL  => undef,
                PRINTTOTAL => undef
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
                        IFNAME   => 'Xerox Embedded Ethernet Controller, 10/100/1000 Mbps, v1.0, RJ45, 100 Mbps full duplex'
                    },
                    {
                        MAC      => '00:00:00:00:00:00',
                        IFNUMBER => '2',
                        IFTYPE   => '24',
                        IFNAME   => 'Xerox internal TCP Software Loopback Interface, v2.0'
                    },
                    {
                        IP => '127.0.0.1'
                    },
                    {
                        IP => '129.181.20.136'
                    }
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
                ID           => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFNAME => 'Xerox Embedded Ethernet Controller, 10/100/1000 Mbps, v1.0, RJ45, 100 Mbps full duplex',
                        MAC => '00:00:AA:CF:84:10',
                        IFTYPE => '6'
                    },
                    {
                        IFTYPE => '24',
                        MAC => '00:00:00:00:00:00',
                        IFNAME => 'Xerox internal TCP Software Loopback Interface, v2.0',
                        IFNUMBER => '2'
                    },
                    {
                        IP => '127.0.0.1'
                    },
                    {
                        IP => '129.181.20.135'
                    }
                ]
            },
            CARTRIDGES => {
                TONERBLACK => 90
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                PRINTTOTAL => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                TOTAL      => undef,
                PRINTCOLOR => undef
            }
        }
    ],
    'xerox/WorkCentre_7125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME => 'XEROX WorkCentre 7125',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => 'PRINTER',
            DESCRIPTION   => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME  => 'XEROX WorkCentre 7125',
            MAC           => undef,
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
                LOCATION     => undef,
                SERIAL       => '3325295030',
                ID           => undef,
                MODEL        => undef,
                MEMORY       => 2,
                NAME         => 'XEROX WorkCentre 7125',
                CONTACT      => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE => 'iso88023Csmacd(7)',
                        IFNUMBER => '1',
                        IFNAME => 'Xerox Embedded Ethernet Controller, 10/100 Mbps, v1.0, RJ45, auto',
                        MAC => ''
                    },
                    {
                        IFTYPE => 'usb(160)',
                        IFNAME => 'Xerox USB-1 - Network Interface',
                        IFNUMBER => '2'
                    },
                    {
                        IFTYPE => 'softwareLoopback(24)',
                        IFNUMBER => '3',
                        IFNAME => 'Xerox Internal TCP Software Loopback Interface'
                    }
                ]
            },
            PAGECOUNTERS => {
                TOTAL => undef,
                COLOR => '6964',
                PRINTBLACK => '3251',
                PRINTTOTAL => '13755',
                BLACK => '4086',
                RECTOVERSO => undef,
                COPYTOTAL => undef,
                SCANNED => undef,
                COPYCOLOR => '1394',
                FAXTOTAL => undef,
                PRINTCOLOR => '6964',
                COPYBLACK => '1311'
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
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Xerox',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
    ],
);

runInventoryTests(%tests);
