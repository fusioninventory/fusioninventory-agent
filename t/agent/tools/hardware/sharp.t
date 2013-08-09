#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'sharp/MX_5001N.1.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'KENET - DPE2',
            MAC          => '00:22:F3:9D:1F:3B',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'KENET - DPE2',
            MAC          => '00:22:F3:9D:1F:3B',
            MODELSNMP    => 'Printer0578',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '9801405X00',
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-5001N',
                MODEL        => 'SHARP MX-5001N',
                ID           => undef,
                SERIAL       => '9801405X00',
                MEMORY       => 0,
                NAME         => 'KENET - DPE2',
                LOCATION     => 'RDC - apers escalier en bois'
            },
            CARTRIDGES => {
                DRUMYELLOW   => -4400,
                TONERCYAN    => 50,
                TONERBLACK   => 75,
                DRUMBLACK    => -2800,
                TONERMAGENTA => 50,
                DRUMMAGENTA  => -4400,
                DRUMCYAN     => -4400,
                TONERYELLOW  => 75
            },
            PORTS => {
                PORT => [
                    {
                        MAC => '00:22:F3:9D:1F:3B',
                        IFNAME => 'Ethernet',
                        IFTYPE => '6',
                        IFNUMBER => '1'
                    }
                ]
            },
            PAGECOUNTERS => {
                RECTOVERSO => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                TOTAL      => undef,
                COPYCOLOR  => undef,
                SCANNED    => undef,
                BLACK      => undef,
                COPYBLACK  => undef,
                FAXTOTAL   => undef,
                PRINTBLACK => undef,
                PRINTTOTAL => undef,
                COLOR      => undef
            },
        }
    ],
    'sharp/MX_5001N.2.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'WASAI -- DFP',
            MAC          => '00:22:F3:9D:20:56',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'WASAI -- DFP',
            MAC          => '00:22:F3:9D:20:56',
            MODELSNMP    => 'Printer0578',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-5001N',
                MODEL        => undef,
                NAME         => 'WASAI -- DFP',
                ID           => undef,
                LOCATION     => '1er etage couloir'
            },
            PORTS => {
                PORT => [
                    {
                        IFTYPE   => '6',
                        IFNAME   => 'Ethernet',
                        IFNUMBER => '1',
                        MAC      => '00:22:F3:9D:20:56'
                    }
                ]
            },
            PAGECOUNTERS => {
                COPYBLACK  => undef,
                BLACK      => undef,
                PRINTCOLOR => undef,
                COPYTOTAL  => undef,
                FAXTOTAL   => undef,
                TOTAL      => undef,
                COLOR      => undef,
                COPYCOLOR  => undef,
                RECTOVERSO => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                PRINTBLACK => undef
            },
        }
    ],
    'sharp/MX_5001N.3.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'MALAKA  - DOS -- IA-IPR',
            MAC          => '00:22:F3:9D:20:4B',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-5001N',
            SNMPHOSTNAME => 'MALAKA  - DOS -- IA-IPR',
            MAC          => '00:22:F3:9D:20:4B',
            MODELSNMP    => 'Printer0578',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => '9801391X00',
        },
        {
            INFO => {
                COMMENTS     => 'SHARP MX-5001N',
                TYPE         => 'PRINTER',
                LOCATION     => 'Bat. R�habilit� ',
                NAME         => 'MALAKA  - DOS -- IA-IPR',
                SERIAL       => '9801391X00',
                MODEL        => 'SHARP MX-5001N',
                MEMORY       => 0,
                ID           => undef,
                MANUFACTURER => 'Sharp'
            },
            PAGECOUNTERS => {
                PRINTCOLOR => undef,
                PRINTBLACK => undef,
                RECTOVERSO => undef,
                BLACK      => undef,
                PRINTTOTAL => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                SCANNED    => undef,
                COLOR      => undef,
                COPYBLACK  => undef,
                COPYCOLOR  => undef,
                COPYTOTAL  => undef
            },
            CARTRIDGES => {
                DRUMCYAN => -750,
                TONERCYAN => 25,
                TONERBLACK => 75,
                DRUMYELLOW => -750,
                TONERYELLOW => 25,
                DRUMMAGENTA => -750,
                TONERMAGENTA => 25,
                DRUMBLACK => -2200
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        MAC => '00:22:F3:9D:20:4B',
                        IFNAME => 'Ethernet',
                        IFTYPE => '6'
                    }
                ]
            }
        }
    ],
    'sharp/MX_2600N.walk' => [
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-2600N',
            SNMPHOSTNAME => 'PASTEK',
            MAC          => '00:22:F3:C8:04:99',
        },
        {
            MANUFACTURER => 'Sharp',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'SHARP MX-2600N',
            SNMPHOSTNAME => 'PASTEK',
            MAC          => '00:22:F3:C8:04:99',
            MODELSNMP    => 'Printer0700',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
        {
            INFO => {
                MANUFACTURER => 'Sharp',
                TYPE         => 'PRINTER',
                COMMENTS     => 'SHARP MX-2600N',
                ID           => undef,
                MODEL        => undef,
                LOCATION     => '2eme etage Bureau POTHIN',
            },
            PAGECOUNTERS => {
                PRINTBLACK => undef,
                COPYTOTAL  => undef,
                COPYCOLOR  => undef,
                TOTAL      => undef,
                FAXTOTAL   => undef,
                COPYBLACK  => undef,
                PRINTCOLOR => undef,
                PRINTTOTAL => undef,
                SCANNED    => undef,
                BLACK      => undef,
                COLOR      => undef,
                RECTOVERSO => undef
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME => 'Ethernet',
                        IFTYPE => '6',
                        MAC => '00:22:F3:C8:04:99',
                        IFNUMBER => '1'
                    },
                    {
                        IP => '172.31.201.123'
                    }
                ]
            }
        }
    ],
);

runInventoryTests(%tests);
