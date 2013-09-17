#!/usr/bin/perl

use strict;
use lib 't/lib';

use Test::Deep qw(cmp_deeply);

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Test::Hardware;

my %tests = (
    'kyocera/TASKalfa-820.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            MAC          => '00:C0:EE:31:84:6B'
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            MAC          => '00:C0:EE:31:84:6B'
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'kyocera/TASKalfa-181.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            MAC          => '00:C0:EE:2F:0D:D9'
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            MAC          => '00:C0:EE:2F:0D:D9'
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'kyocera/FS-2000D.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            MAC          => '00:C0:EE:6A:96:DD',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
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
                MEMORY       => 0,
                TYPE         => 'PRINTER'
            },
            CARTRIDGES => {
                WASTETONER => 100,
                TONERBLACK => 75
            },
            PORTS => {
                PORT => [
                    {
                        IFNAME   => 'eth0',
                        IFTYPE   => 'ethernetCsmacd(6)',
                        MAC      => '00:C0:EE:6A:96:DD',
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
            MAC          => '00:C0:EE:6A:97:07',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
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
                SERIAL       => 'XLM7Y21503',
                MODEL        => 'FS-2000D',
                ID           => undef,
                MEMORY       => 0
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
                        MAC      => '00:C0:EE:6A:97:07'
                    }
                ]
            }
        }
    ],
    'kyocera/utax_ta.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'UTAX_TA Printing System',
            MAC          => '00:C0:EE:80:DD:2D',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'UTAX_TA Printing System',
            MAC          => '00:C0:EE:80:DD:2D',
            MODELSNMP    => 'Networking2073',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'Q250Z01068',
        },
        {
            INFO => {
                ID           => undef,
                MANUFACTURER => 'Kyocera',
                TYPE         => 'NETWORKING',
                MODEL        => undef,
                SERIAL       => 'Q250Z01068',
                COMMENTS     => 'UTAX_TA Printing System',
            },
            PORTS => {
                PORT => [
                    {
                        IFNUMBER => '1',
                        IFTYPE   => '6',
                        IP       => '10.104.154.211',
                        MAC      => '00:C0:EE:80:DD:2D'
                    }
                ]
            },
        }
    ],
    'kyocera/F-5350DN.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:CA:DD',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:CA:DD',
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'kyocera/F-5350DN.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:73:71',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:73:71',
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
        }
    ],
    'kyocera/F-5350DN.3.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:73:6C',
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-C5350DN',
            MAC          => '00:C0:EE:80:73:6C',
        },
        {
            INFO => {
                MANUFACTURER => 'Kyocera',
                TYPE         => 'PRINTER',
                ID           => undef,
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
    use Data::Dumper;

    my $device3 = getDeviceFullInfo(
        snmp  => $snmp,
        model => $model,
    );
    cmp_deeply($device3, $tests{$test}->[2], "$test: base + model stage");
}
