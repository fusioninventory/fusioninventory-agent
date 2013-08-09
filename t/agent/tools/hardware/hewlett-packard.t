#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::More;
use Test::Deep;
use YAML qw(LoadFile);

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;
use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Utils;

my %tests = (
    'hewlett-packard/unknown.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
        },
        {
            INFO => {
                TYPE         => undef,
                MANUFACTURER => 'Hewlett-Packard',
                ID           => undef,
                MODEL        => undef
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                COLOR      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                TOTAL      => undef,
                COPYCOLOR  => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/Inkjet_2800.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
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
                TYPE         => undef,
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
            PAGECOUNTERS => {
                RECTOVERSO => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef
            },
        }
    ],
    'hewlett-packard/Inkjet_2800.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
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
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM V.29.11,JETDIRECT,JD115,EEPROM V.29.13,CIDATE 08/11/2005',
                MODEL        => 'HP Business Inkjet 2800',
                MEMORY       => 96,
                ID           => undef,
                NAME         => 'HPIJ2800-01',
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                COPYTOTAL  => undef,
                BLACK      => undef,
                SCANNED    => undef,
                COLOR      => undef,
                RECTOVERSO => undef,
                TOTAL      => undef,
                PRINTBLACK => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef
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
            TYPE         => undef,
            DESCRIPTION  => 'Officejet Pro K5400',
            SNMPHOSTNAME => 'HP560332',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Officejet Pro K5400',
            SNMPHOSTNAME => 'HP560332',
            MAC          => undef,
            MODELSNMP    => 'Printer0285',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                NAME         => 'HP560332',
                ID           => undef,
                LOCATION     => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                FAXTOTAL   => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                TOTAL      => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef
            },
            CARTRIDGES => {
                CARTRIDGEYELLOW  => 6,
                CARTRIDGECYAN    => 290,
                CARTRIDGEMAGENTA => 20,
                CARTRIDGEBLACK   => 9
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/OfficeJet_Pro_8600.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'Officejet Pro 8600 N911g',
            SNMPHOSTNAME => 'HP8C0C51',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'Officejet Pro 8600 N911g',
            SNMPHOSTNAME => 'HP8C0C51',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => undef,
                TYPE         => undef,
                ID           => undef
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                TOTAL      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_100_colorMFP_M175nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => undef,
            MODELSNMP    => 'Printer0718',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NPIF6FA4A',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet 100 colorMFP M175nw',
                CONTACT      => undef,
                ID           => undef,
                NAME         => 'NPIF6FA4A',
                MODEL        => 'HP LaserJet 100 colorMFP M175nw',
                SERIAL       => 'NPIF6FA4A',
                LOCATION     => undef
            },
            CARTRIDGES => {
                TONERBLACK   => 31,
                TONERYELLOW  => 82,
                TONERMAGENTA => 82,
                DRUMBLACK    => 96,
                TONERCYAN    => 83
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                RECTOVERSO => undef,
                TOTAL      => '367',
                PRINTCOLOR => undef,
                COLOR      => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                BLACK      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_400_color_M451dn.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => undef,
            MODELSNMP    => 'Printer0730',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCF300725',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet 400 color M451dn',
                CONTACT      => undef,
                NAME         => 'NPIF67498',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                LOCATION     => undef,
                MODEL        => 'HP LaserJet 400 color M451dn',
                SERIAL       => 'CNCF300725'
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                COLOR      => '507',
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                TOTAL      => undef,
                RECTOVERSO => '0',
                PRINTTOTAL => '541',
                FAXTOTAL   => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERMAGENTA => 73,
                TONERCYAN => 68,
                TONERBLACK => 53
            },
        }
    ],
    'hewlett-packard/LaserJet_1320.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => undef,
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW59NG6N',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                OTHERSERIAL  => '0x0115',
                LOCATION     => undef,
                SERIAL       => 'CNHW59NG6N',
                MODEL        => 'hp LaserJet 1320 series',
                ID           => undef,
                NAME         => 'NPI61044B',
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COLOR      => undef,
                PRINTTOTAL => undef,
                BLACK      => undef,
                RECTOVERSO => '1935',
                SCANNED    => undef,
                COPYBLACK  => undef,
                TOTAL      => '33545',
                PRINTCOLOR => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_1320.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => undef,
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW625K6Z',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                LOCATION     => undef,
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
                BLACK      => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                TOTAL      => '45790',
                COLOR      => undef,
                PRINTTOTAL => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                FAXTOTAL   => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_1320.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => undef,
            MODELSNMP    => 'Printer0606',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW49FHC4',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM B.25.01,JETDIRECT,JD119,EEPROM V.28.05,CIDATE 04/22/2004',
                SERIAL       => 'CNBW49FHC4',
                LOCATION     => undef,
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPIC68F5E',
                ID           => undef,
                MODEL        => 'hp LaserJet 1320 series'
            },
            PAGECOUNTERS => {
                TOTAL      => '5868',
                COPYBLACK  => undef,
                SCANNED    => undef,
                RECTOVERSO => '258',
                BLACK      => undef,
                PRINTTOTAL => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                PRINTCOLOR => undef
            },
            PORTS => {
                PORT => []
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
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COLOR      => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                SCANNED    => undef,
                TOTAL      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_2100.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                MODEL        => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                COLOR      => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                SCANNED    => undef,
                TOTAL      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_2600n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => undef,
            MODELSNMP    => 'Printer0093',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                NAME         => 'NPI1864A0',
                MODEL        => undef,
                ID           => undef,
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                FAXTOTAL   => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                PRINTTOTAL => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                SCANNED    => undef,
                TOTAL      => undef,
                COLOR      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_3600.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => undef,
            MODELSNMP    => 'Printer0390',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNXJD65169',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD121,EEPROM V.30.31,CIDATE 06/17/2005',
                NAME         => 'NPI6F72C5',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP Color LaserJet 3600',
                ID           => undef,
                LOCATION     => undef,
                SERIAL       => 'CNXJD65169',
            },
            PAGECOUNTERS => {
                PRINTBLACK => undef,
                PRINTTOTAL => undef,
                COPYTOTAL  => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                COLOR      => '9946',
                PRINTCOLOR => undef,
                RECTOVERSO => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                TOTAL      => undef,
                COPYCOLOR  => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERMAGENTA => 46,
                TONERYELLOW  => 45,
                TONERBLACK   => 63,
                TONERCYAN    => 44
            }
        }
    ],
    'hewlett-packard/LaserJet_4250.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => undef,
            MODELSNMP    => 'Printer0078',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCXG01622'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD128,EEPROM V.28.43,CIDATE 06/23/2004',
                NAME         => 'impKirat',
                SERIAL       => 'CNCXG01622',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                LOCATION     => undef,
                MODEL        => 'hp LaserJet 4250'
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                SCANNED    => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                FAXTOTAL   => undef
            },
            CARTRIDGES => {
                TONERBLACK     => 52,
                MAINTENANCEKIT => 56
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_5550.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => undef,
            MODELSNMP    => 'Printer0614',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'SG96304AD8'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'hp color LaserJet 5550 ',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                SERIAL       => 'SG96304AD8',
                LOCATION     => undef,
                MODEL        => 'hp color LaserJet 5550 ',
                CONTACT      => undef,
                NAME         => 'IDD116',
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERYELLOW  => 96,
                TONERCYAN    => 95,
                TONERBLACK   => 12,
                TONERMAGENTA => 95
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                RECTOVERSO => '0',
                TOTAL      => undef,
                SCANNED    => undef,
                BLACK      => '102279',
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                COPYTOTAL  => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                COLOR      => '92447'
            }
        }
    ],
    'hewlett-packard/LaserJet_CM1312nfi_MFP.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => undef,
            MODELSNMP    => 'Printer0396',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNB885QNXP'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNB885QNXP,FN:NL106CH,SVCID:18334,PID:HP Color LaserJet CM1312nfi MFP',
                NAME         => 'NPI271E90',
                LOCATION     => 'HP Color LaserJet CM1312nfi MFP',
                MODEL        => 'HP Color LaserJet CM1312nfi MFP',
                OTHERSERIAL  => '0x0115',
                SERIAL       => 'CNB885QNXP',
                ID           => undef
            },
            PAGECOUNTERS => {
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                TOTAL      => undef,
                COLOR      => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                BLACK      => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef
            },
            PORTS => {
                PORT => []
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
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => undef,
            MODELSNMP    => 'Printer0575',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNF8BC11FK,FN:QD30T49,SVCID:21055,PID:HP LaserJet CM1415fn',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'HP LaserJet CM1415fn',
                LOCATION     => undef,
                NAME         => 'B536-lwc237-Fax',
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERCYAN => 35,
                TONERMAGENTA => 31,
                TONERYELLOW => 33,
                TONERBLACK => 25
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                TOTAL      => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                PRINTBLACK => undef,
                BLACK      => '760',
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                COLOR      => '4720',
                PRINTTOTAL => undef,
                RECTOVERSO => '0'
            }
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFN9BYG41'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                LOCATION     => 'HP Color LaserJet CM2320fxi MFP',
                SERIAL       => 'CNFN9BYG41',
                NAME         => 'NPI7F5D71',
                MODEL        => 'HP Color LaserJet CM2320fxi MFP',
                OTHERSERIAL  => '0x0115',
                ID           => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK   => 43,
                TONERMAGENTA => 41,
                TONERYELLOW  => 18,
                TONERCYAN    => 46
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                SCANNED    => undef,
                BLACK      => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                COPYTOTAL  => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFN9BYG41'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
                PORT => []
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => undef,
                COLOR      => undef,
                TOTAL      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => undef,
            MODELSNMP    => 'Printer0550',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNDN99YG0D'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                SERIAL       => 'CNDN99YG0D',
                LOCATION     => 'HP Color LaserJet CM2320fxi MFP',
                NAME         => 'NPI828833',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                MODEL        => 'HP Color LaserJet CM2320fxi MFP'
            },
            PAGECOUNTERS => {
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                COPYTOTAL  => undef,
                COLOR      => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                PRINTCOLOR => undef
            },
            PORTS => {
                PORT => []
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
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFTBDZ0FN',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNFTBDZ0FN,FN:PT60J59,SVCID:21046,PID:HP Color LaserJet CM2320nf MFP',
                MODEL        => 'HP Color LaserJet CM2320nf MFP',
                SERIAL       => 'CNFTBDZ0FN',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPIB302A7',
                ID           => undef,
                LOCATION     => 'HP Color LaserJet CM2320nf MFP'
            },
            PAGECOUNTERS => {
                TOTAL      => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                COLOR      => '789',
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                BLACK      => '141',
                RECTOVERSO => '0',
                PRINTTOTAL => undef
            },
            PORTS => {
                PORT => []
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
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => undef,
            MODELSNMP    => 'Printer0414',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCSF01053',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
                TOTAL      => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                BLACK      => '9817',
                PRINTCOLOR => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                COLOR      => '21930'
            },
            CARTRIDGES => {
                TONERYELLOW  => 34,
                TONERCYAN    => 34,
                TONERMAGENTA => 18,
                TONERBLACK   => 19
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => undef,
            MODELSNMP    => 'Printer0414',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHS437790',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNHS437790,FN:MB27295,SVCID:22039,PID:HP Color LaserJet CP2025dn',
                MODEL        => 'HP Color LaserJet CP2025dn',
                ID           => undef,
                SERIAL       => 'CNHS437790',
                NAME         => 'NPIC3D5FF',
                OTHERSERIAL  => '0x0115',
                LOCATION     => 'HP Color LaserJet CP2025dn'
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                BLACK      => '1198',
                PRINTBLACK => undef,
                RECTOVERSO => '1',
                COLOR      => '7501',
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                SCANNED    => undef,
                COPYBLACK  => undef
            },
            CARTRIDGES => {
                TONERYELLOW => 24,
                TONERMAGENTA => 33,
                TONERCYAN => 48,
                TONERBLACK => 89
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHSP65440',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                BLACK      => '1145',
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                RECTOVERSO => '0',
                PRINTTOTAL => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS404796',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS404796,FN:MB04VB0,SVCID:19316,PID:HP Color LaserJet CP2025n',
                ID           => undef,
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNCS404796',
                NAME         => 'NPI84C481',
                MODEL        => 'HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
            },
            CARTRIDGES => {
                TONERBLACK => 31,
                TONERMAGENTA => 32,
                TONERCYAN => 69,
                TONERYELLOW => 77
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                BLACK      => '3459',
                COLOR      => '11263',
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                RECTOVERSO => '0',
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTTOTAL => undef,
                TOTAL      => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS404796',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS404796,FN:MB04VB0,SVCID:19316,PID:HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPI84C481',
                MODEL        => 'HP Color LaserJet CP2025n',
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNCS404796',
                ID           => undef
            },
            PAGECOUNTERS => {
                TOTAL      => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                PRINTTOTAL => undef,
                RECTOVERSO => '0',
                COPYBLACK  => undef,
                BLACK      => '3896',
                COLOR      => '12731',
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                COPYTOTAL  => undef
            },
            PORTS => {
                PORT => []
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
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCS212370',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNCS212370,FN:MB03SY2,SVCID:19127,PID:HP Color LaserJet CP2025n',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP Color LaserJet CP2025n',
                NAME         => 'NPI81E3A7',
                SERIAL       => 'CNCS212370',
                LOCATION     => 'HP Color LaserJet CP2025n',
                ID           => undef
            },
            CARTRIDGES => {
                TONERBLACK => 41,
                TONERMAGENTA => 47,
                TONERYELLOW => 63,
                TONERCYAN => 93
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                COLOR      => '16450',
                BLACK      => '5506',
                COPYBLACK  => undef,
                RECTOVERSO => '0',
                PRINTTOTAL => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                PRINTBLACK => undef,
                TOTAL      => undef
            },
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => undef,
            MODELSNMP    => 'Printer0393',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHSN58554',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNHSN58554,FN:MB258FW,SVCID:21095,PID:HP Color LaserJet CP2025n',
                LOCATION     => 'HP Color LaserJet CP2025n',
                SERIAL       => 'CNHSN58554',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                NAME         => 'NPI8FA1DD',
                MODEL        => 'HP Color LaserJet CP2025n'
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                SCANNED    => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                COLOR      => '5758',
                BLACK      => '3843',
                COPYBLACK  => undef,
                RECTOVERSO => '0'
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK   => 55,
                TONERMAGENTA => 23,
                TONERYELLOW  => 29,
                TONERCYAN    => 18
            }
        }
    ],
    'hewlett-packard/LaserJet_P2015_Series.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => undef,
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW898043',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW898043,FN:JK5FJN3,SVCID:18327,PID:HP LaserJet P2015 Series',
                SERIAL       => 'CNBW898043',
                ID           => undef,
                NAME         => 'NPI83EC85',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P2015 Series',
                LOCATION     => 'Boise, ID, USA'
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 44
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                COLOR      => '0',
                FAXTOTAL   => undef,
                TOTAL      => undef,
                RECTOVERSO => '0',
                PRINTBLACK => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                PRINTTOTAL => undef,
                BLACK      => '36596'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2015_Series.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => undef,
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW7BQ7BS',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW7BQ7BS,FN:JK44SRD,SVCID:18021,PID:HP LaserJet P2015 Series',
                OTHERSERIAL  => '0x0115',
                LOCATION     => 'Boise, ID, USA',
                MODEL        => 'HP LaserJet P2015 Series',
                SERIAL       => 'CNBW7BQ7BS',
                NAME         => 'NPI13EE63',
                ID           => undef
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                COLOR      => '0',
                FAXTOTAL   => undef,
                RECTOVERSO => '0',
                PRINTBLACK => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                BLACK      => '25333',
                PRINTTOTAL => undef
            },
            CARTRIDGES => {
                TONERBLACK => 59
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_P2015_Series.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => undef,
            SNMPHOSTNAME => 'NPI83EC85',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => undef,
            SNMPHOSTNAME => 'NPI83EC85',
            MODELSNMP    => 'Printer0394',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW898043',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,SN:CNBW898043,FN:JK5FJN3,SVCID:18327,PID:HP LaserJet P2015 Series',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P2015 Series',
                LOCATION     => 'Boise, ID, USA',
                SERIAL       => 'CNBW898043',
                ID           => undef,
                NAME         => 'NPI83EC85',
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                COLOR      => '0',
                TOTAL      => undef,
                RECTOVERSO => '0',
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => undef,
                BLACK      => '36301',
                COPYTOTAL  => undef,
                SCANNED    => undef
            },
            CARTRIDGES => {
                TONERBLACK => 50
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet-P4014.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
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
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41,CIDATE 06/12/2009',
                NAME         => 'NPIFFF0F2',
                ID           => undef,
                MODEL        => 'HP LaserJet P4014',
                SERIAL       => 'CNFX409800',
                MEMORY       => 384
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                SCANNED    => undef,
                BLACK      => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                RECTOVERSO => undef,
                COLOR      => undef
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
                FIRMWARE     => 'K.15.28 K.15.04.0015m',
                ID           => undef,
                SERIAL       => 'SG707SU03Y',
                MAC          => '00:18:71:C1:E0:00',
                CONTACT      => 'systeme@ac-guyane.fr',
                LOCATION     => 'datacenter',
                UPTIME       => '(293555959) 33 days, 23:25:59.59',
                MODEL        => undef,
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
            PAGECOUNTERS => {
                BLACK      => undef,
                COLOR      => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                PRINTCOLOR => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'A1',
                        MAC => '00:18:71:C1:F0:FF',
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1349379502',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(137791) 0:22:57.91',
                        IFINOCTETS => '2281257823',
                        IFTYPE => '6',
                        IFNUMBER => '1',
                        IFNAME => 'A1'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'A2',
                        MAC => '00:18:71:C1:F0:FE',
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '351638347',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(137791) 0:22:57.91',
                        IFINOCTETS => '1790849661',
                        IFNUMBER => '2',
                        IFTYPE => '6',
                        IFNAME => 'A2'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '1368455180',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(140056) 0:23:20.56',
                        IFINOCTETS => '2596611853',
                        IFTYPE => '6',
                        IFNUMBER => '3',
                        IFNAME => 'A3',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'A3',
                        MAC => '00:18:71:C1:F0:FD'
                    },
                    {
                        IFOUTOCTETS => '205027037',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '1000000000',
                        IFTYPE => '6',
                        IFNUMBER => '4',
                        IFNAME => 'A4',
                        IFLASTCHANGE => '(140106) 0:23:21.06',
                        IFINOCTETS => '2096487256',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'A4',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:FC'
                    },
                    {
                        IFNAME => 'A5',
                        IFNUMBER => '5',
                        IFTYPE => '6',
                        IFINOCTETS => '2759835685',
                        IFLASTCHANGE => '(98419) 0:16:24.19',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '2189748070',
                        IFSPEED => '1000000000',
                        MAC => '00:18:71:C1:F0:FB',
                        IFINERRORS => '0',
                        IFDESCR => 'A5',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFLASTCHANGE => '(98419) 0:16:24.19',
                        IFINOCTETS => '710340837',
                        IFTYPE => '6',
                        IFNUMBER => '6',
                        IFNAME => 'A6',
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '1497261298',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        MAC => '00:18:71:C1:F0:FA',
                        IFOUTERRORS => '0',
                        IFDESCR => 'A6',
                        IFINERRORS => '0',
                        IFSTATUS => '1'
                    },
                    {
                        MAC => '00:18:71:C1:F0:F9',
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'A7',
                        IFINOCTETS => '264235442',
                        IFLASTCHANGE => '(133722) 0:22:17.22',
                        IFNAME => 'A7',
                        IFTYPE => '6',
                        IFNUMBER => '7',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1045414825'
                    },
                    {
                        MAC => '00:18:71:C1:F0:F8',
                        IFOUTERRORS => '0',
                        IFDESCR => 'A8',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFLASTCHANGE => '(133722) 0:22:17.22',
                        IFINOCTETS => '2740877036',
                        IFNUMBER => '8',
                        IFTYPE => '6',
                        IFNAME => 'A8',
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1496580095',
                        IFMTU => '1500'
                    },
                    {
                        IFINOCTETS => '1383661651',
                        IFLASTCHANGE => '(171654) 0:28:36.54',
                        IFNAME => 'A9',
                        IFTYPE => '6',
                        IFNUMBER => '9',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1593815865',
                        MAC => '00:18:71:C1:F0:F7',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'A9',
                        IFSTATUS => '1'
                    },
                    {
                        IFDESCR => 'A10',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:F6',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1552508202',
                        IFSPEED => '1000000000',
                        IFNAME => 'A10',
                        IFTYPE => '6',
                        IFNUMBER => '10',
                        IFINOCTETS => '2224332599',
                        IFLASTCHANGE => '(171654) 0:28:36.54'
                    },
                    {
                        MAC => '00:18:71:C1:F0:F5',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFOUTERRORS => '0',
                        IFNUMBER => '11',
                        IFTYPE => '6',
                        IFNAME => 'A11',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '0',
                        IFSPEED => '0'
                    },
                    {
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFNAME => 'A12',
                        IFTYPE => '6',
                        IFNUMBER => '12',
                        IFSPEED => '0',
                        IFMTU => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        MAC => '00:18:71:C1:F0:F4',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2'
                    },
                    {
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '2302731832',
                        IFSPEED => '1000000000',
                        IFNAME => 'A13',
                        IFTYPE => '6',
                        IFNUMBER => '13',
                        IFINOCTETS => '3735158120',
                        IFLASTCHANGE => '(147598) 0:24:35.98',
                        IFDESCR => 'A13',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:F3'
                    },
                    {
                        IFNAME => 'A14',
                        IFNUMBER => '14',
                        IFTYPE => '6',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFMTU => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:F0:F2',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFDESCR => 'A15',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:F0:F1',
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '284146569',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(154728) 0:25:47.28',
                        IFINOCTETS => '3361365604',
                        IFTYPE => '6',
                        IFNUMBER => '15',
                        IFNAME => 'A15'
                    },
                    {
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFTYPE => '6',
                        IFNUMBER => '16',
                        IFNAME => 'A16',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '0',
                        MAC => '00:18:71:C1:F0:F0',
                        IFOUTERRORS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0'
                    },
                    {
                        MAC => '00:18:71:C1:F0:EF',
                        IFINERRORS => '0',
                        IFDESCR => 'A17',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'A17',
                        IFTYPE => '6',
                        IFNUMBER => '17',
                        IFINOCTETS => '348605692',
                        IFLASTCHANGE => '(152568) 0:25:25.68',
                        IFMTU => '1500',
                        IFOUTOCTETS => '2435360597',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '1000000000'
                    },
                    {
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '0',
                        IFSPEED => '0',
                        IFTYPE => '6',
                        IFNUMBER => '18',
                        IFNAME => 'A18',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:EE'
                    },
                    {
                        MAC => '00:18:71:C1:F0:ED',
                        IFDESCR => 'A19',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'A19',
                        IFTYPE => '6',
                        IFNUMBER => '19',
                        IFINOCTETS => '28689859',
                        IFLASTCHANGE => '(143621) 0:23:56.21',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1786194494',
                        IFSPEED => '1000000000'
                    },
                    {
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFNUMBER => '20',
                        IFTYPE => '6',
                        IFNAME => 'A20',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        MAC => '00:18:71:C1:F0:EC'
                    },
                    {
                        IFINOCTETS => '2943397531',
                        IFLASTCHANGE => '(94699) 0:15:46.99',
                        IFNAME => 'A21',
                        IFNUMBER => '21',
                        IFTYPE => '6',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '1009676074',
                        IFINTERNALSTATUS => '1',
                        MAC => '00:18:71:C1:F0:EB',
                        IFOUTERRORS => '0',
                        IFDESCR => 'A21',
                        IFINERRORS => '0',
                        IFSTATUS => '1'
                    },
                    {
                        MAC => '00:18:71:C1:F0:EA',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'A22',
                        IFINOCTETS => '3614341248',
                        IFLASTCHANGE => '(57936) 0:09:39.36',
                        IFNAME => 'A22',
                        IFNUMBER => '22',
                        IFTYPE => '6',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '372261477',
                        IFINTERNALSTATUS => '1'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '3322662505',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(57936) 0:09:39.36',
                        IFINOCTETS => '1968825162',
                        IFTYPE => '6',
                        IFNUMBER => '23',
                        IFNAME => 'A23',
                        IFOUTERRORS => '0',
                        IFDESCR => 'A23',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:F0:E9'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'A24',
                        MAC => '00:18:71:C1:F0:E8',
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '2284145698',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(57936) 0:09:39.36',
                        IFINOCTETS => '3412112397',
                        IFNUMBER => '24',
                        IFTYPE => '6',
                        IFNAME => 'A24'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1169469549',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(147667) 0:24:36.67',
                        IFINOCTETS => '1056898244',
                        IFNUMBER => '25',
                        IFTYPE => '6',
                        IFNAME => 'B1',
                        IFOUTERRORS => '0',
                        IFDESCR => 'B1',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:F0:E7'
                    },
                    {
                        IFINOCTETS => '3042721785',
                        IFLASTCHANGE => '(147617) 0:24:36.17',
                        IFNAME => 'B2',
                        IFNUMBER => '26',
                        IFTYPE => '6',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '558861009',
                        IFINTERNALSTATUS => '1',
                        MAC => '00:18:71:C1:F0:E6',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'B2',
                        IFSTATUS => '1'
                    },
                    {
                        MAC => '00:18:71:C1:F0:E5',
                        IFINERRORS => '0',
                        IFDESCR => 'B3',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'B3',
                        IFNUMBER => '27',
                        IFTYPE => '6',
                        IFINOCTETS => '3237184662',
                        IFLASTCHANGE => '(154748) 0:25:47.48',
                        IFMTU => '1500',
                        IFOUTOCTETS => '146927983',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '1000000000'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '3299335483',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(154797) 0:25:47.97',
                        IFINOCTETS => '2288807394',
                        IFNUMBER => '28',
                        IFTYPE => '6',
                        IFNAME => 'B4',
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'B4',
                        MAC => '00:18:71:C1:F0:E4'
                    },
                    {
                        MAC => '00:18:71:C1:F0:E3',
                        IFINERRORS => '0',
                        IFDESCR => 'B5',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFTYPE => '6',
                        IFNUMBER => '29',
                        IFNAME => 'B5',
                        IFLASTCHANGE => '(152588) 0:25:25.88',
                        IFINOCTETS => '3318685559',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '2809203793',
                        IFMTU => '1500',
                        IFSPEED => '1000000000'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFDESCR => 'B6',
                        MAC => '00:18:71:C1:F0:E2',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2632) 0:00:26.32',
                        IFNAME => 'B6',
                        IFNUMBER => '30',
                        IFTYPE => '6'
                    },
                    {
                        MAC => '00:18:71:C1:F0:E1',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'B7',
                        IFLASTCHANGE => '(143699) 0:23:56.99',
                        IFINOCTETS => '3012845819',
                        IFNUMBER => '31',
                        IFTYPE => '6',
                        IFNAME => 'B7',
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '2231577010',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'B8',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:E0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '3764354101',
                        IFMTU => '1500',
                        IFSPEED => '1000000000',
                        IFTYPE => '6',
                        IFNUMBER => '32',
                        IFNAME => 'B8',
                        IFLASTCHANGE => '(143699) 0:23:56.99',
                        IFINOCTETS => '3323194516'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '20030667',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(94732) 0:15:47.32',
                        IFINOCTETS => '3754573618',
                        IFTYPE => '6',
                        IFNUMBER => '33',
                        IFNAME => 'B9',
                        IFOUTERRORS => '0',
                        IFDESCR => 'B9',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:F0:DF'
                    },
                    {
                        IFMTU => '1500',
                        IFOUTOCTETS => '2884232004',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '1000000000',
                        IFNAME => 'B10',
                        IFTYPE => '6',
                        IFNUMBER => '34',
                        IFINOCTETS => '1557689030',
                        IFLASTCHANGE => '(94732) 0:15:47.32',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'B10',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:DE'
                    },
                    {
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFNUMBER => '35',
                        IFTYPE => '6',
                        IFNAME => 'B11',
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '0',
                        MAC => '00:18:71:C1:F0:DD',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2'
                    },
                    {
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFNUMBER => '36',
                        IFTYPE => '6',
                        IFNAME => 'B12',
                        IFOUTERRORS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0',
                        MAC => '00:18:71:C1:F0:DC'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '1019288656',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '1205644070',
                        IFLASTCHANGE => '(137672) 0:22:56.72',
                        IFNAME => 'B13',
                        IFNUMBER => '37',
                        IFTYPE => '6',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'B13',
                        MAC => '00:18:71:C1:F0:DB'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        MAC => '00:18:71:C1:F0:DA',
                        IFSPEED => '0',
                        IFMTU => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFNAME => 'B14',
                        IFNUMBER => '38',
                        IFTYPE => '6'
                    },
                    {
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '3131610378',
                        IFMTU => '1500',
                        IFSPEED => '1000000000',
                        IFTYPE => '6',
                        IFNUMBER => '39',
                        IFNAME => 'B15',
                        IFLASTCHANGE => '(139982) 0:23:19.82',
                        IFINOCTETS => '2981067194',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'B15',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:D9'
                    },
                    {
                        IFMTU => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0',
                        IFNAME => 'B16',
                        IFNUMBER => '40',
                        IFTYPE => '6',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:D8'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'B17',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:D7',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1435860196',
                        IFMTU => '1500',
                        IFSPEED => '1000000000',
                        IFNUMBER => '41',
                        IFTYPE => '6',
                        IFNAME => 'B17',
                        IFLASTCHANGE => '(98347) 0:16:23.47',
                        IFINOCTETS => '2496990832'
                    },
                    {
                        MAC => '00:18:71:C1:F0:D6',
                        IFOUTERRORS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFTYPE => '6',
                        IFNUMBER => '42',
                        IFNAME => 'B18',
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'B19',
                        MAC => '00:18:71:C1:F0:D5',
                        IFSPEED => '1000000000',
                        IFOUTOCTETS => '2304461112',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(133655) 0:22:16.55',
                        IFINOCTETS => '3225589631',
                        IFTYPE => '6',
                        IFNUMBER => '43',
                        IFNAME => 'B19'
                    },
                    {
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFTYPE => '6',
                        IFNUMBER => '44',
                        IFNAME => 'B20',
                        IFOUTERRORS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0',
                        MAC => '00:18:71:C1:F0:D4'
                    },
                    {
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '4215478562',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '3403667845',
                        IFLASTCHANGE => '(171619) 0:28:36.19',
                        IFNAME => 'B21',
                        IFTYPE => '6',
                        IFNUMBER => '45',
                        IFOUTERRORS => '0',
                        IFDESCR => 'B21',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:F0:D3'
                    },
                    {
                        IFINOCTETS => '2524887906',
                        IFLASTCHANGE => '(57873) 0:09:38.73',
                        IFNAME => 'B22',
                        IFNUMBER => '46',
                        IFTYPE => '6',
                        IFSPEED => '1000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '986787144',
                        MAC => '00:18:71:C1:F0:D2',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'B22',
                        IFSTATUS => '1'
                    },
                    {
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '1527530290',
                        IFMTU => '1500',
                        IFSPEED => '1000000000',
                        IFNUMBER => '47',
                        IFTYPE => '6',
                        IFNAME => 'B23',
                        IFLASTCHANGE => '(57873) 0:09:38.73',
                        IFINOCTETS => '1647940696',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'B23',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:F0:D1'
                    },
                    {
                        MAC => '00:18:71:C1:F0:D0',
                        IFDESCR => 'B24',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'B24',
                        IFNUMBER => '48',
                        IFTYPE => '6',
                        IFINOCTETS => '2411859653',
                        IFLASTCHANGE => '(57873) 0:09:38.73',
                        IFMTU => '1500',
                        IFOUTOCTETS => '2515291862',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '1000000000'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'Trk2',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFLASTCHANGE => '(140222) 0:23:22.22',
                        IFINOCTETS => '3379199007',
                        IFNUMBER => '291',
                        IFTYPE => '161',
                        IFNAME => 'Trk2',
                        IFSPEED => '3000000000',
                        IFOUTOCTETS => '410125299',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'Trk4',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '3000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '949597094',
                        IFINOCTETS => '3667291251',
                        IFLASTCHANGE => '(152649) 0:25:26.49',
                        IFNAME => 'Trk4',
                        IFTYPE => '161',
                        IFNUMBER => '293'
                    },
                    {
                        IFSPEED => '3000000000',
                        IFOUTOCTETS => '4031062390',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(147706) 0:24:37.06',
                        IFINOCTETS => '3539810853',
                        IFTYPE => '161',
                        IFNUMBER => '295',
                        IFNAME => 'Trk6',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'Trk6',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'Trk8',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFMTU => '1500',
                        IFOUTOCTETS => '3066835333',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '3000000000',
                        IFNAME => 'Trk8',
                        IFNUMBER => '297',
                        IFTYPE => '161',
                        IFINOCTETS => '2716694799',
                        IFLASTCHANGE => '(171701) 0:28:37.01'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'Trk10',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFINOCTETS => '2069762898',
                        IFLASTCHANGE => '(143756) 0:23:57.56',
                        IFNAME => 'Trk10',
                        IFTYPE => '161',
                        IFNUMBER => '299',
                        IFSPEED => '3000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '3487158309'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'Trk12',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '2720306505',
                        IFSPEED => '3000000000',
                        IFNAME => 'Trk12',
                        IFNUMBER => '301',
                        IFTYPE => '161',
                        IFINOCTETS => '982784258',
                        IFLASTCHANGE => '(137833) 0:22:58.33'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'Trk14',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '3000000000',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '551488736',
                        IFINOCTETS => '1935734813',
                        IFLASTCHANGE => '(133781) 0:22:17.81',
                        IFNAME => 'Trk14',
                        IFTYPE => '161',
                        IFNUMBER => '303'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'Trk16',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFLASTCHANGE => '(98455) 0:16:24.55',
                        IFINOCTETS => '1672200058',
                        IFNUMBER => '305',
                        IFTYPE => '161',
                        IFNAME => 'Trk16',
                        IFSPEED => '3000000000',
                        IFOUTOCTETS => '827902268',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        IFSPEED => '3000000000',
                        IFMTU => '1500',
                        IFOUTOCTETS => '3913938745',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '3960692883',
                        IFLASTCHANGE => '(94806) 0:15:48.06',
                        IFNAME => 'Trk18',
                        IFTYPE => '161',
                        IFNUMBER => '307',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'Trk18',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFNUMBER => '309',
                        IFTYPE => '161',
                        IFNAME => 'Trk20',
                        IFLASTCHANGE => '(154845) 0:25:48.45',
                        IFINOCTETS => '297423068',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '3730410035',
                        IFMTU => '1500',
                        IFSPEED => '3000000000',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFDESCR => 'Trk20',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFNAME => 'Trk21',
                        IFNUMBER => '310',
                        IFTYPE => '161',
                        IFINOCTETS => '2695065174',
                        IFLASTCHANGE => '(57970) 0:09:39.70',
                        IFMTU => '1500',
                        IFOUTOCTETS => '2418744384',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '4294967295',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFDESCR => 'Trk21',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFTYPE => '53',
                        IFNUMBER => '578',
                        IFNAME => 'DEFAULT_VLAN',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFDESCR => 'DEFAULT_VLAN',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFDESCR => 'VLAN2',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFNUMBER => '579',
                        IFTYPE => '53',
                        IFNAME => 'VLAN2'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN3',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFNUMBER => '580',
                        IFTYPE => '53',
                        IFNAME => 'VLAN3',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN4',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFTYPE => '53',
                        IFNUMBER => '581',
                        IFNAME => 'VLAN4',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN5',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFTYPE => '53',
                        IFNUMBER => '582',
                        IFNAME => 'VLAN5',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0'
                    },
                    {
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN6',
                        IFNUMBER => '583',
                        IFTYPE => '53',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN6',
                        IFSTATUS => '1'
                    },
                    {
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN7',
                        IFTYPE => '53',
                        IFNUMBER => '584',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'VLAN7',
                        IFINERRORS => '0',
                        IFSTATUS => '1'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN13',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN13',
                        IFTYPE => '53',
                        IFNUMBER => '590'
                    },
                    {
                        IFNAME => 'VLAN14',
                        IFTYPE => '53',
                        IFNUMBER => '591',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN14',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0',
                        IFNAME => 'VLAN15',
                        IFNUMBER => '592',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN15',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFTYPE => '53',
                        IFNUMBER => '593',
                        IFNAME => 'VLAN16',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN16',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFTYPE => '53',
                        IFNUMBER => '594',
                        IFNAME => 'VLAN17',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN17',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFTYPE => '53',
                        IFNUMBER => '595',
                        IFNAME => 'VLAN18',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN18',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFTYPE => '53',
                        IFNUMBER => '599',
                        IFNAME => 'VLAN22',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN22',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN30',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN30',
                        IFTYPE => '53',
                        IFNUMBER => '607'
                    },
                    {
                        IFNUMBER => '726',
                        IFTYPE => '53',
                        IFNAME => 'VLAN149',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN149',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN150',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'VLAN150',
                        IFNUMBER => '727',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN152',
                        IFOUTERRORS => '0',
                        IFNAME => 'VLAN152',
                        IFNUMBER => '729',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN153',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFTYPE => '53',
                        IFNUMBER => '730',
                        IFNAME => 'VLAN153'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'VLAN154',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN154',
                        IFNUMBER => '731',
                        IFTYPE => '53',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN155',
                        IFOUTERRORS => '0',
                        IFNAME => 'VLAN155',
                        IFNUMBER => '732',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN156',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFNAME => 'VLAN156',
                        IFTYPE => '53',
                        IFNUMBER => '733',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN157',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFTYPE => '53',
                        IFNUMBER => '734',
                        IFNAME => 'VLAN157',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0'
                    },
                    {
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFNUMBER => '735',
                        IFTYPE => '53',
                        IFNAME => 'VLAN158',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN158',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFNUMBER => '736',
                        IFTYPE => '53',
                        IFNAME => 'VLAN159',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN159',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN160',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFTYPE => '53',
                        IFNUMBER => '737',
                        IFNAME => 'VLAN160',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0'
                    },
                    {
                        IFNAME => 'VLAN162',
                        IFNUMBER => '739',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(110183700) 12 days, 18:03:57.00',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN162',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN170',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFTYPE => '53',
                        IFNUMBER => '747',
                        IFNAME => 'VLAN170'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN171',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFNUMBER => '748',
                        IFTYPE => '53',
                        IFNAME => 'VLAN171'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFDESCR => 'VLAN172',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFNUMBER => '749',
                        IFTYPE => '53',
                        IFNAME => 'VLAN172',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN180',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNUMBER => '757',
                        IFTYPE => '53',
                        IFNAME => 'VLAN180',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN190',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFNUMBER => '767',
                        IFTYPE => '53',
                        IFNAME => 'VLAN190',
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500'
                    },
                    {
                        IFTYPE => '53',
                        IFNUMBER => '773',
                        IFNAME => 'VLAN196',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN196',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFDESCR => 'VLAN201',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFTYPE => '53',
                        IFNUMBER => '778',
                        IFNAME => 'VLAN201'
                    },
                    {
                        IFNAME => 'VLAN202',
                        IFNUMBER => '779',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN202',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN204',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        IFNAME => 'VLAN204',
                        IFNUMBER => '781',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFSPEED => '0'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN205',
                        IFSTATUS => '1',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFNAME => 'VLAN205',
                        IFTYPE => '53',
                        IFNUMBER => '782',
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0'
                    },
                    {
                        IFTYPE => '53',
                        IFNUMBER => '791',
                        IFNAME => 'VLAN214',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN214',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFNUMBER => '792',
                        IFTYPE => '53',
                        IFNAME => 'VLAN215',
                        IFLASTCHANGE => '(2663) 0:00:26.63',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN215',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFNAME => 'VLAN401',
                        IFTYPE => '53',
                        IFNUMBER => '978',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(110183690) 12 days, 18:03:56.90',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFDESCR => 'VLAN401',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN402',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00',
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFNUMBER => '979',
                        IFTYPE => '53',
                        IFNAME => 'VLAN402'
                    },
                    {
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFMTU => '1500',
                        IFLASTCHANGE => '(2658) 0:00:26.58',
                        IFINOCTETS => '0',
                        IFTYPE => '53',
                        IFNUMBER => '980',
                        IFNAME => 'VLAN403',
                        IFOUTERRORS => '0',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN403',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN3000',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFMTU => '1500',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        IFNAME => 'VLAN3000',
                        IFNUMBER => '3577',
                        IFTYPE => '53',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(57880) 0:09:38.80'
                    },
                    {
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN3002',
                        IFSTATUS => '1',
                        IFOUTERRORS => '0',
                        MAC => '00:18:71:C1:E0:00',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFSPEED => '0',
                        IFNUMBER => '3579',
                        IFTYPE => '53',
                        IFNAME => 'VLAN3002',
                        IFLASTCHANGE => '(57880) 0:09:38.80',
                        IFINOCTETS => '0'
                    },
                    {
                        IFSPEED => '0',
                        IFMTU => '1500',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(57880) 0:09:38.80',
                        IFNAME => 'VLAN3006',
                        IFTYPE => '53',
                        IFNUMBER => '3583',
                        IFOUTERRORS => '0',
                        IFDESCR => 'VLAN3006',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        MAC => '00:18:71:C1:E0:00'
                    },
                    {
                        MAC => '00:18:71:C1:E0:00',
                        IFSTATUS => '1',
                        IFINERRORS => '0',
                        IFDESCR => 'VLAN3007',
                        IFOUTERRORS => '0',
                        IFNUMBER => '3584',
                        IFTYPE => '53',
                        IFNAME => 'VLAN3007',
                        IFLASTCHANGE => '(57880) 0:09:38.80',
                        IFINOCTETS => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '0',
                        IFMTU => '1500',
                        IFSPEED => '0'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFINERRORS => '0',
                        IFSTATUS => '1',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '7893971',
                        IFNUMBER => '4672',
                        IFTYPE => '24',
                        IFNAME => 'lo0',
                        IFSPEED => '0',
                        IFINTERNALSTATUS => '1',
                        IFOUTOCTETS => '7774747',
                        IFMTU => '65535'
                    },
                    {
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFOUTERRORS => '0',
                        IFTYPE => '24',
                        IFNUMBER => '4673',
                        IFNAME => 'lo1',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '2',
                        IFMTU => '9198',
                        IFSPEED => '0'
                    },
                    {
                        IFSPEED => '0',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '2',
                        IFMTU => '9198',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFNUMBER => '4674',
                        IFTYPE => '24',
                        IFNAME => 'lo2',
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFDESCR => 'HP ProCurve Switch software loopback interface'
                    },
                    {
                        IFOUTERRORS => '0',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFNAME => 'lo3',
                        IFTYPE => '24',
                        IFNUMBER => '4675',
                        IFSPEED => '0',
                        IFMTU => '9198',
                        IFOUTOCTETS => '0',
                        IFINTERNALSTATUS => '2'
                    },
                    {
                        IFMTU => '9198',
                        IFINTERNALSTATUS => '2',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        IFNAME => 'lo4',
                        IFNUMBER => '4676',
                        IFTYPE => '24',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFNAME => 'lo5',
                        IFNUMBER => '4677',
                        IFTYPE => '24',
                        IFINOCTETS => '0',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFMTU => '9198',
                        IFINTERNALSTATUS => '2',
                        IFOUTOCTETS => '0',
                        IFSPEED => '0',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFINERRORS => '0',
                        IFSTATUS => '2',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFINTERNALSTATUS => '2',
                        IFOUTOCTETS => '0',
                        IFMTU => '9198',
                        IFSPEED => '0',
                        IFTYPE => '24',
                        IFNUMBER => '4678',
                        IFNAME => 'lo6',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFINERRORS => '0',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFSTATUS => '2',
                        IFOUTERRORS => '0'
                    },
                    {
                        IFINTERNALSTATUS => '2',
                        IFOUTOCTETS => '0',
                        IFMTU => '9198',
                        IFSPEED => '0',
                        IFNUMBER => '4679',
                        IFTYPE => '24',
                        IFNAME => 'lo7',
                        IFLASTCHANGE => '(0) 0:00:00.00',
                        IFINOCTETS => '0',
                        IFSTATUS => '2',
                        IFINERRORS => '0',
                        IFDESCR => 'HP ProCurve Switch software loopback interface',
                        IFOUTERRORS => '0'
                    }
                ]
            },
        }

    ],
    'hewlett-packard/LaserJet_CP1025nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            MAC          => undef,
            SNMPHOSTNAME => 'NPIA6032E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            SNMPHOSTNAME => 'NPIA6032E',
            MAC          => undef,
            MODELSNMP    => 'Printer0532',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT',
                MODEL        => 'HP LaserJet CP1025nw',
                LOCATION     => ' ',
                ID           => undef,
                NAME         => 'NPIA6032E'
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                FAXTOTAL => undef,
                PRINTBLACK => undef,
                BLACK => '91',
                SCANNED => undef,
                PRINTTOTAL => undef,
                RECTOVERSO => undef,
                TOTAL => undef,
                COPYBLACK => undef,
                COPYTOTAL => undef,
                PRINTCOLOR => undef,
                COLOR => undef,
                COPYCOLOR => undef
            },
        }
    ],
    'hewlett-packard/LaserJet_P3005.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => undef,
            MODELSNMP    => 'Printer0612',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '0x0115434E4831523036363335'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P3005',
                OTHERSERIAL  => '0x0115',
                ID           => undef,
                LOCATION     => undef,
                NAME         => 'NPI7A5E2D',
                SERIAL       => 'CNH1R06635',
                MODEL        => '0x0115513738313441'
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 32
            },
            PAGECOUNTERS => {
                BLACK => undef,
                FAXTOTAL => undef,
                RECTOVERSO => '0',
                COPYBLACK => undef,
                COPYCOLOR => undef,
                COLOR => undef,
                PRINTTOTAL => undef,
                COPYTOTAL => undef,
                PRINTCOLOR => undef,
                TOTAL => undef,
                PRINTBLACK => undef,
                SCANNED => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                NAME         => 'NPI7E0932',
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => '20040201',
                ID           => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 6
            },
            PAGECOUNTERS => {
                RECTOVERSO => '433',
                COLOR      => '0',
                PRINTBLACK => '30965',
                PRINTTOTAL => '30965',
                COPYBLACK  => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                BLACK      => '30965',
                COPYTOTAL  => undef,
                TOTAL      => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                COMMENTS     => 'HP LaserJet P2055dn',
                TYPE         => undef,
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => 'HP LaserJet P2055dn',
                ID           => undef,
                SERIAL       => '20040201',
                NAME         => 'NPI8DDF43',
                OTHERSERIAL  => '0xFDE8'
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                TOTAL      => undef,
                BLACK      => '36105',
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                PRINTBLACK => '36105',
                PRINTTOTAL => '36105',
                COLOR      => '0',
                RECTOVERSO => '8379'
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 88
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPI830993',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 32
            },
            PAGECOUNTERS => {
                RECTOVERSO => '62',
                COLOR      => '0',
                COPYBLACK  => undef,
                PRINTTOTAL => '3837',
                PRINTBLACK => '3837',
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                TOTAL      => undef,
                COPYTOTAL  => undef,
                BLACK      => '3837'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                SERIAL       => '20040201',
                NAME         => 'NPI83E8D5',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
            },
            PAGECOUNTERS => {
                COLOR => '0',
                RECTOVERSO => '5297',
                PRINTTOTAL => '11057',
                PRINTBLACK => '11057',
                COPYBLACK => undef,
                COPYCOLOR => undef,
                FAXTOTAL => undef,
                SCANNED => undef,
                PRINTCOLOR => undef,
                BLACK => '11057',
                COPYTOTAL => undef,
                TOTAL => undef
            },
            CARTRIDGES => {
                TONERBLACK => 45
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                NAME         => 'NPI886B5B',
                OTHERSERIAL  => '0xFDE8',
                SERIAL       => '20040201',
                ID           => undef,
                MODEL        => 'HP LaserJet P2055dn',
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 56
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                SCANNED    => undef,
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                BLACK      => '19402',
                COPYTOTAL  => undef,
                TOTAL      => undef,
                COLOR      => '0',
                RECTOVERSO => '3761',
                PRINTBLACK => '19402',
                PRINTTOTAL => '19402',
                COPYBLACK  => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                PRINTTOTAL => '17861',
                FAXTOTAL => undef,
                TOTAL => undef,
                BLACK => '17861',
                COPYCOLOR => undef,
                COLOR => '0',
                PRINTBLACK => '17861',
                COPYTOTAL => undef,
                COPYBLACK => undef,
                PRINTCOLOR => undef,
                SCANNED => undef,
                RECTOVERSO => '3192'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COLOR      => '0',
                PRINTBLACK => '5696',
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                RECTOVERSO => '1843',
                PRINTTOTAL => '5696',
                FAXTOTAL   => undef,
                TOTAL      => undef,
                BLACK      => '5696',
                COPYCOLOR  => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                ID           => undef,
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPICB3982',
                MODEL        => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 38
            },
            PAGECOUNTERS => {
                RECTOVERSO => '6952',
                SCANNED    => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTBLACK => '26922',
                COLOR      => '0',
                BLACK      => '26922',
                COPYCOLOR  => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                PRINTTOTAL => '26922'
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                NAME         => 'NPIC08394',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                BLACK      => '4047',
                FAXTOTAL   => undef,
                RECTOVERSO => '50',
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                COLOR      => '0',
                COPYTOTAL  => undef,
                PRINTTOTAL => '4047',
                PRINTCOLOR => undef,
                TOTAL      => undef,
                PRINTBLACK => '4047',
                SCANNED    => undef
            },
            CARTRIDGES => {
                TONERBLACK => 20
            },
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.10.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                MODEL        => 'HP LaserJet P2055dn',
                SERIAL       => '20040201',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'NPICBD8B1',
                ID           => undef
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                PRINTTOTAL => '4944',
                PRINTBLACK => '4944',
                COLOR      => '0',
                RECTOVERSO => '0',
                COPYTOTAL  => undef,
                TOTAL      => undef,
                BLACK      => '4944',
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 40
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.11.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P2055dn',
                ID           => undef,
                SERIAL       => '20040201',
                NAME         => 'NPIB979A2',
                OTHERSERIAL  => '0xFDE8',
                MODEL        => 'HP LaserJet P2055dn',
            },
            PAGECOUNTERS => {
                COPYTOTAL => undef,
                TOTAL => undef,
                BLACK => '4339',
                PRINTCOLOR => undef,
                SCANNED => undef,
                FAXTOTAL => undef,
                COPYCOLOR => undef,
                COPYBLACK => undef,
                PRINTBLACK => '4339',
                PRINTTOTAL => '4339',
                COLOR => '0',
                RECTOVERSO => '498'
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_P2055dn.12.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => undef,
            MODELSNMP    => 'Printer0611',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '20040201',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
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
                COPYBLACK  => undef,
                PRINTBLACK => '89242',
                PRINTTOTAL => '89242',
                PRINTCOLOR => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                TOTAL      => undef,
                COPYTOTAL  => undef,
                BLACK      => '89242'
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 68
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY417951'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36,CIDATE 04/10/2008',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'LJ30000000000000000000----------',
                SERIAL       => 'CNFY417951',
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK     => 100,
                MAINTENANCEKIT => 87
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                RECTOVERSO => '26',
                PRINTTOTAL => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY409032'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.36,CIDATE 04/10/2008',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI8D9896',
                SERIAL       => 'CNFY409032',
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK     => 64,
                MAINTENANCEKIT => 61
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                RECTOVERSO => '26',
                PRINTTOTAL => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY213364'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.35,CIDATE 09/18/2007',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI22C87C',
                SERIAL       => 'CNFY213364',
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK     => 34,
                MAINTENANCEKIT => 79
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                RECTOVERSO => '52',
                PRINTTOTAL => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY183496'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.40,CIDATE 02/24/2009',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPI9706DE',
                SERIAL       => 'CNFY183496',
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                MAINTENANCEKIT => 5,
                TONERBLACK     => 1
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                RECTOVERSO => '4',
                PRINTTOTAL => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_P4015.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFY349204'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD143,EEPROM V.36.41,CIDATE 06/12/2009',
                ID           => undef,
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet P4015',
                NAME         => 'NPIEADBFB',
                SERIAL       => 'CNFY349204',
                LOCATION     => undef
            },
            PORTS => {
                PORT => []
            },
            CARTRIDGES => {
                TONERBLACK => 32
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                COLOR      => undef,
                RECTOVERSO => '2096',
                PRINTTOTAL => undef
            }
        }
    ],
    'hewlett-packard/LaserJet_CP4520.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => undef,
            MODELSNMP    => 'Printer0639',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'JPCTC8M0LJ',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD145,EEPROM V.38.99,CIDATE 11/26/2010',
                ID           => undef,
                SERIAL       => 'JPCTC8M0LJ',
                OTHERSERIAL  => '0xFDE8',
                LOCATION     => undef,
                MODEL        => 'HP Color LaserJet CP4520 Series',
                NAME         => 'NPI10DB2C',
                CONTACT      => undef
            },
            PAGECOUNTERS => {
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                COLOR      => '5839',
                COPYBLACK  => undef,
                SCANNED    => undef,
                BLACK      => '8881',
                PRINTCOLOR => '5839',
                FAXTOTAL   => undef,
                TOTAL      => undef,
                RECTOVERSO => undef,
                PRINTBLACK => '8765',
                PRINTTOTAL => '14610'
            },
            CARTRIDGES => {
                TONERMAGENTA => 44,
                TONERCYAN    => 47,
                TONERYELLOW  => 50
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_CP3525.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => undef,
            MODELSNMP    => 'Printer0388',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCT98DGJY',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.67,CIDATE 06/17/2008',
                ID           => undef,
                LOCATION     => undef,
                SERIAL       => 'CNCT98DGJY',
                NAME         => 'NPI85A57D',
                MODEL        => 'HP Color LaserJet CP3525',
                OTHERSERIAL  => '0xFDE8',
            },
            CARTRIDGES => {
                TONERBLACK => 67,
                TONERYELLOW => 30,
                TONERCYAN => 39,
                TONERMAGENTA => 21
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                BLACK      => '7603',
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                COLOR      => '9127',
                RECTOVERSO => '0',
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                PRINTTOTAL => undef,
                TOTAL      => undef
            },
        }
    ],
    'hewlett-packard/LaserJet_CP3525.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => undef,
            MODELSNMP    => 'Printer0388',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNCTB9PHWG',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD146,EEPROM V.38.80,CIDATE 11/03/2009',
                OTHERSERIAL  => '0xFDE8',
                NAME         => 'Corinne',
                MODEL        => 'HP Color LaserJet CP3525',
                LOCATION     => undef,
                SERIAL       => 'CNCTB9PHWG',
                ID           => undef
            },
            PAGECOUNTERS => {
                RECTOVERSO => '49',
                COPYBLACK  => undef,
                BLACK      => '7256',
                COLOR      => '11905',
                COPYCOLOR  => undef,
                FAXTOTAL   => undef,
                COPYTOTAL  => undef,
                TOTAL      => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                PRINTCOLOR => undef,
                PRINTTOTAL => undef
            },
            CARTRIDGES => {
                TONERYELLOW => 8,
                TONERCYAN => 21,
                TONERMAGENTA => 97,
                TONERBLACK => 53
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_P3010.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
            MODELSNMP    => 'Printer0402',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'VNBQD3C0BF'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet P3010 Series',
                OTHERSERIAL  => '0xFDE8',
                ID           => undef,
                LOCATION     => undef,
                SERIAL       => 'VNBQD3C0BF',
                NAME         => 'NPI013B81',
                MODEL        => 'HP LaserJet P3010 Series',
            },
            PAGECOUNTERS => {
                RECTOVERSO => '74',
                PRINTBLACK => undef,
                TOTAL => undef,
                FAXTOTAL => undef,
                SCANNED => undef,
                COPYTOTAL => undef,
                PRINTTOTAL => undef,
                COPYCOLOR => undef,
                COLOR => undef,
                PRINTCOLOR => undef,
                BLACK => '15265',
                COPYBLACK => undef
            },
            CARTRIDGES => {
                TONERBLACK => 84
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'hewlett-packard/LaserJet_P3010.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
            MODELSNMP    => 'Printer0402',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'VNBQD3C0BF'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE        => undef,
                COMMENTS    => 'HP LaserJet P3010 Series',
                ID          => undef,
                OTHERSERIAL => '0xFDE8',
                LOCATION    => undef,
                SERIAL      => 'VNBQD3C0BF',
                NAME        => 'NPI013B81',
                MODEL       => 'HP LaserJet P3010 Series',
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                COLOR      => undef,
                COPYBLACK  => undef,
                BLACK      => '6386',
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                RECTOVERSO => '772',
                TOTAL      => undef,
                PRINTBLACK => undef
            },
            CARTRIDGES => {
                TONERBLACK => 1
            }
        }
    ],
    'hewlett-packard/LaserJet_500.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
            MODELSNMP    => 'Printer0628',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'SE00V4T'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM none,JETDIRECT,JD149,EEPROM V50251103114,CIDATE 11/17/2011',
                NAME         => 'NPI419F6E',
                MODEL        => 'HP LaserJet 500 color M551',
                SERIAL       => 'SE00V4T',
                ID           => undef,
                LOCATION     => undef
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                BLACK      => '1685',
                SCANNED    => undef,
                PRINTTOTAL => undef,
                RECTOVERSO => undef,
                TOTAL      => undef,
                COLOR      => '6601',
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef,
                COPYTOTAL  => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_600.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => undef,
                ID           => undef,
                TYPE         => undef
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                COLOR      => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                BLACK      => undef,
                PRINTTOTAL => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                TOTAL      => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_600.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                MODEL        => undef,
                ID           => undef,
                TYPE         => undef
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                COLOR      => undef,
                PRINTBLACK => undef,
                FAXTOTAL   => undef,
                BLACK      => undef,
                PRINTTOTAL => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                COPYBLACK  => undef,
                TOTAL      => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_4000.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => undef,
            MODELSNMP    => 'Printer0391',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NLEW064384',
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM G.05.35,JETDIRECT,JD30,EEPROM G.05.35',
                LOCATION     => 'lwcompta',
                SERIAL       => 'NLEW064384',
                OTHERSERIAL  => '0x0115',
                MODEL        => 'HP LaserJet 4000 Series',
                ID           => undef,
                NAME         => 'inspiron8',
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                RECTOVERSO => '152',
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                PRINTCOLOR => undef,
                BLACK      => undef,
                SCANNED    => undef,
                TOTAL      => undef,
                COLOR      => undef,
                COPYTOTAL  => undef,
                PRINTTOTAL => undef,
                COPYCOLOR  => undef
            },
            CARTRIDGES => {
                TONERBLACK => 100
            }
        }
    ],
    'hewlett-packard/LaserJet_4050.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => undef,
            MODELSNMP    => 'Printer0615',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'NL7N093250'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP LaserJet 4050 Series ',
                SERIAL       => 'NL7N093250',
                CONTACT      => undef,
                OTHERSERIAL  => '0x011520',
                NAME         => 'imprimanteBR',
                MODEL        => 'HP LaserJet 4050 Series ',
                ID           => undef,
                LOCATION     => 'impbe93'
            },
            PAGECOUNTERS => {
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                COPYBLACK  => undef,
                TOTAL      => '252311',
                RECTOVERSO => '0',
                COPYTOTAL  => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                COLOR      => undef,
                PRINTTOTAL => undef,
                PRINTCOLOR => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'hewlett-packard/LaserJet_4200.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => undef,
            MODELSNMP    => 'Printer0386',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNFX305387'
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                COMMENTS     => 'HP ETHERNET MULTI-ENVIRONMENT,ROM R.22.01,JETDIRECT,JD95,EEPROM R.25.09,CIDATE 07/24/2003',
                SERIAL       => 'CNFX305387',
                OTHERSERIAL  => '0x0115',
                NAME         => 'IMP41200n0',
                LOCATION     => undef,
                ID           => undef,
                MODEL        => 'hp LaserJet 4200'
            },
            PORTS => {
                PORT => []
            },
            PAGECOUNTERS => {
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => '0',
                COPYTOTAL  => undef,
                BLACK      => undef,
                PRINTBLACK => undef,
                COLOR      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                PRINTCOLOR => undef
            },
            CARTRIDGES => {
                TONERBLACK     => 95,
                MAINTENANCEKIT => 71
            }
        }
    ],
    'hewlett-packard/LaserJet_1300n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Hewlett-Packard',
                TYPE         => undef,
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                COLOR      => undef,
                TOTAL      => undef,
                SCANNED    => undef,
                COPYBLACK  => undef,
                RECTOVERSO => undef,
                BLACK      => undef,
                FAXTOTAL   => undef,
                PRINTCOLOR => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef,
                PRINTBLACK => undef
            },
            PORTS => {
                PORT => []
            },
        }
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} elsif (!$ENV{SNMPMODEL_DATABASE}) {
    plan skip_all => 'SNMP models database required';
} else {
    plan tests => 3 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => "$ENV{SNMPMODEL_DATABASE}/dictionary.xml"
);

my $index = LoadFile("$ENV{SNMPMODEL_DATABASE}/index.yaml");

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my %device0 = getDeviceInfo($snmp);
    my %device1 = getDeviceInfo($snmp, $dictionary);
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
    my $model_id = $tests{$test}->[1]->{MODELSNMP};
    my $model = $model_id ?
        loadModel("$ENV{SNMPMODEL_DATABASE}/$index->{$model_id}") : undef;

    my $device3 = FusionInventory::Agent::Tools::Hardware::getDeviceFullInfo(
        device => {
            FILE => "$ENV{SNMPWALK_DATABASE}/$test",
            TYPE => 'PRINTER',
        },
        model => $model
    );
    cmp_deeply($device3, $tests{$test}->[2], $test);
}
