#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'kyocera/TASKalfa-820.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:31:84:6B'
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:31:84:6B'
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'kyocera/TASKalfa-181.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:2F:0D:D9'
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:2F:0D:D9'
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'kyocera/FS-2000D.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:6A:96:DD',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:6A:96:DD',
            MODELSNMP    => 'Printer0351',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21506',
        },
        {
            INFO => {
                SERIAL       => 'XLM7Y21506',
                ID           => undef,
                COMMENTS     => 'KYOCERA MITA Printing System',
                MODEL        => 'FS-2000D',
                MANUFACTURER => 'Kyocera',
                LOCATION     => undef,
                MEMORY       => 0,
                NAME         => undef,
                TYPE         => 'PRINTER'
            },
            CARTRIDGES => {
                WASTETONER => 100,
                TONERBLACK => 75
            },
            PAGECOUNTERS => {
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                SCANNED    => undef,
                COLOR      => undef,
                PRINTBLACK => undef,
                BLACK      => undef,
                RECTOVERSO => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                TOTAL      => undef,
                PRINTCOLOR => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'eth0',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '',
                        IFNUMBER => '1',
                        IP       => '172.20.3.51'
                    }
                ]
            }
        }
    ],
    'kyocera/FS-2000D.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:6A:97:07',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => '00:C0:EE:6A:97:07',
            MODELSNMP    => 'Printer0351',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'XLM7Y21503',
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                COMMENTS     => 'KYOCERA MITA Printing System',
                NAME         => undef,
                SERIAL       => 'XLM7Y21503',
                MODEL        => 'FS-2000D',
                LOCATION     => undef,
                ID           => undef,
                MEMORY       => 0
            },
            PAGECOUNTERS => {
                COPYTOTAL  => undef,
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                SCANNED    => undef,
                FAXTOTAL   => undef,
                COPYCOLOR  => undef,
                PRINTBLACK => undef,
                COPYBLACK  => undef,
                BLACK      => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                COLOR      => undef
            },
            CARTRIDGES  => {
                TONERBLACK => 37,
                WASTETONER => 100
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'eth0',
                        IP       => '172.20.3.4',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        IFNUMBER => '1',
                        MAC      => ''
                    }
                ]
            }
        }
    ],
);

runInventoryTests(%tests);
