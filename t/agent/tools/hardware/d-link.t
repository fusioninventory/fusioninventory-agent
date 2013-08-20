#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'd-link/DP_303.1.walk' => [
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5D:57:B3:C4'
        },
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => '00:05:5D:57:B3:C4'
        }

    ],
    'd-link/DP_303.2.walk' => [
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5D:57:B3:C7'
        },
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => '00:05:5D:57:B3:C7'
        }
    ],
);

runDiscoveryTests(%tests);
