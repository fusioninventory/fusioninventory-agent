#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'canon/LBP7660C_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon LBP7660C /P',
            SNMPHOSTNAME => 'LBP7660C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon LBP7660C /P',
            SNMPHOSTNAME => 'LBP7660C',
            MAC          => undef,
            MODELSNMP    => 'Printer0790',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                ID           => undef,
                LOCATION     => undef,
                CONTACT      => undef,
                NAME         => 'LBP7660C',
                MODEL        => 'Canon LBP7660C',
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
            },
        }
    ],
    'canon/MF4500_Series_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => undef
        },
        {
            INFO => {
                MANUFACTURER => 'Canon',
                TYPE         => 'PRINTER',
                ID           => undef,
            },
            PORTS => {
                PORT => []
            },
        }
    ],
);

runInventoryTests(%tests);
