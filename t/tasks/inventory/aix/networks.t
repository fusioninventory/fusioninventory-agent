#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::AIX::Networks;

my %tests = (
    'aix-4.3.1' => [
        {
            DESCRIPTION => 'en0',
            MACADDR     => '08:00:5A:BA:E9:67',
            TYPE        => 'ethernet'
        }
    ],
    'aix-4.3.2' => [
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:20:35:B5:8B:46',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en0',
            MACADDR     => '08:00:5A:BA:EB:DA',
            TYPE        => 'ethernet'
        }
    ],
    'aix-5.3a' => [
        {
            DESCRIPTION => 'en0',
            MACADDR     => '00:14:5E:4D:20:C6',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:14:5E:4D:20:C7',
            TYPE        => 'ethernet'
        }
    ],
    'aix-5.3b' => [
        {
            DESCRIPTION => 'en0',
            MACADDR     => '00:14:5E:9C:93:00',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:14:5E:9C:93:01',
            TYPE        => 'ethernet'
        }
    ],
    'aix-5.3c' => [
        {
            DESCRIPTION => 'en2',
            MACADDR     => '8E:72:9C:98:E6:04',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:21:5E:0B:42:79',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en0',
            MACADDR     => '00:21:5E:0B:42:78',
            TYPE        => 'ethernet'
        }
    ],
    'aix-6.1a' => [
        {
            DESCRIPTION => 'en0',
            MACADDR     => 'D2:13:C0:15:3A:04',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en2',
            MACADDR     => '00:21:5E:A6:7C:D0',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:21:5E:A6:7C:C0',
            TYPE        => 'ethernet'
        }
    ],
    'aix-6.1b' => [
        {
            DESCRIPTION => 'en0',
            MACADDR     => '00:21:5E:4C:C7:68',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en1',
            MACADDR     => '00:21:5E:4C:C7:69',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en3',
            MACADDR     => '00:1A:64:86:42:31',
            TYPE        => 'ethernet'
        },
        {
            DESCRIPTION => 'en2',
            MACADDR     => '00:1A:64:86:42:30',
            TYPE        => 'ethernet'
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lscfg/$test-en";
    my @interfaces = FusionInventory::Agent::Task::Inventory::Input::AIX::Networks::_parseLscfg(file => $file);
    cmp_deeply(\@interfaces, $tests{$test}, "interfaces: $test");
}
