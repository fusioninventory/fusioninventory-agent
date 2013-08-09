#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'd-link/DP_303.1.walk' => [
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => undef
        },
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C4',
            MAC          => undef
        }

    ],
    'd-link/DP_303.2.walk' => [
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => undef
        },
        {
            DESCRIPTION  => 'D-Link DP-303 Print Server',
            SNMPHOSTNAME => 'Print Server PS-57B3C7',
            MAC          => undef
        }
    ],
);

runDiscoveryTests(%tests);
