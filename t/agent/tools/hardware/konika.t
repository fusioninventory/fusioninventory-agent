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
            MAC          => '00:50:AA:27:95:9E'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => '00:50:AA:27:95:9E'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                COLOR      => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                RECTOVERSO => undef
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
            MAC          => '00:50:AA:27:96:68'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => '00:50:AA:27:96:68'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                COLOR      => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                RECTOVERSO => undef
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
            MAC          => '00:50:AA:27:95:A3'
        },
        {
            MANUFACTURER => 'Konica',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'KONICA MINOLTA bizhub 421',
            SNMPHOSTNAME => '',
            MAC          => '00:50:AA:27:95:A3'
        },
        {
            INFO => {
                MANUFACTURER => 'Konica',
                TYPE         => 'PRINTER',
                ID           => undef,
                MODEL        => undef,
            },
            PAGECOUNTERS => {
                BLACK      => undef,
                COPYCOLOR  => undef,
                PRINTCOLOR => undef,
                TOTAL      => undef,
                PRINTTOTAL => undef,
                FAXTOTAL   => undef,
                COLOR      => undef,
                COPYTOTAL  => undef,
                COPYBLACK  => undef,
                PRINTBLACK => undef,
                SCANNED    => undef,
                RECTOVERSO => undef
            },
            PORTS => {
                PORT => []
            }
        }
    ],
);

runInventoryTests(%tests);
