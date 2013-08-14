#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'dell/M5200.1.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.14 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKE6E33E-2',
            MAC          => '00:04:00:67:C7:7C',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'dell/M5200.2.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'Dell Laser Printer M5200 version 55.10.19 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXKB92115',
            MAC          => '00:04:00:9D:84:A8',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
    'dell/unknown.walk' => [
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            MANUFACTURER => 'Dell',
            TYPE         => undef,
            DESCRIPTION  => 'DELL NETWORK PRINTER,ROM A.03.15,JETDIRECT,JD24,EEPROM A.08.20',
            SNMPHOSTNAME => 'DEL0000f0aceaa9',
            MAC          => '00:00:F0:AC:EA:A9',
        },
        {
            INFO => {
                MANUFACTURER => 'Dell',
                TYPE         => undef,
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
);

runInventoryTests(%tests);
