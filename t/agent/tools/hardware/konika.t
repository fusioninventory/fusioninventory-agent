#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'konica/bizhub_421.1.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'konica/bizhub_421.2.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            }
        }
    ],
    'konica/bizhub_421.3.walk' => [
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
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
