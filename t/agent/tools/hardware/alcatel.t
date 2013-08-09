#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'alcatel/unknown.1.walk' => [
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CB-C005-127-os6400',
            MAC          => 'E8:E7:32:2B:C1:E2',
        },
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CB-C005-127-os6400',
            MAC          => 'E8:E7:32:2B:C1:E2',
            MODELSNMP    => 'Networking2189',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'M4682816',
        }
    ],
    'alcatel/unknown.2.walk' => [
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CP-153-127',
            MAC          => 'E8:E7:32:2B:C1:E2',
        },
        {
            MANUFACTURER => 'Alcatel-Lucent',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Alcatel-Lucent 6.4.4.342.R01 GA, April 18, 2011.',
            SNMPHOSTNAME => 'CP-153-127',
            MAC          => 'E8:E7:32:2B:C1:E2',
            MODELSNMP    => 'Networking2189',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'M4682816',
        }
    ]
);

runDiscoveryTests(%tests);
