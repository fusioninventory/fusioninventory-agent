#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'ddwrt/unknown.1.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'nasbcs',
            SNMPHOSTNAME => 'nasbcs',
            MAC          => '00:14:FD:14:35:2C',
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'nasbcs',
            SNMPHOSTNAME => 'nasbcs',
            MAC          => '00:14:FD:14:35:2C',
        }
    ],
    'ddwrt/unknown.2.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'Linux nasbcs 2.6.33N7700 #5 SMP Wed Jan 26 12:14:33 CST 2011 i686',
            SNMPHOSTNAME => undef,
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'Linux nasbcs 2.6.33N7700 #5 SMP Wed Jan 26 12:14:33 CST 2011 i686',
            SNMPHOSTNAME => undef,
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.3.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'aleph.bu.dauphine.fr',
            SNMPHOSTNAME => 'aleph.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'aleph.bu.dauphine.fr',
            SNMPHOSTNAME => 'aleph.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.4.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primotest.bu.dauphine.fr',
            SNMPHOSTNAME => 'primotest.bu.dauphine.fr',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primotest.bu.dauphine.fr',
            SNMPHOSTNAME => 'primotest.bu.dauphine.fr',
            MAC          => undef
        }
    ],
    'ddwrt/unknown.5.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primo.bu.dauphine.fr',
            SNMPHOSTNAME => 'primo.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'primo.bu.dauphine.fr',
            SNMPHOSTNAME => 'primo.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
    'ddwrt/unknown.6.walk' => [
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'metalib.bu.dauphine.fr',
            SNMPHOSTNAME => 'metalib.bu.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ddwrt',
            TYPE         => undef,
            DESCRIPTION  => 'metalib.bu.dauphine.fr',
            SNMPHOSTNAME => 'metalib.bu.dauphine.fr',
            MAC          => undef,
        }
    ],
);

runDiscoveryTests(%tests);
