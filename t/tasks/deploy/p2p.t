#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Deploy::P2P;

my @tests = (
    {
        name => 'Ignore',
        test => [
            {
                ip   => '127.0.0.1',
                mask => '255.0.0.0'
            }
        ],
        ret => [
        ]
    },
    {
        name => '192.168.5.5',
        test => [
            {
                ip   => '192.168.5.5',
                mask => '255.255.255.0'
            },
        ],
        ret => [
          '192.168.5.2',
          '192.168.5.3',
          '192.168.5.4',
          '192.168.5.5',
          '192.168.5.6',
          '192.168.5.7'
        ]
    },
    {
        name => '10.5.6.200',
        test => [
            {
                ip   => '10.5.6.200',
                mask => '255.255.250.0'
            }
        ],
        ret => [
          '10.5.6.197',
          '10.5.6.198',
          '10.5.6.199',
          '10.5.6.200',
          '10.5.6.201',
          '10.5.6.202'
        ]
    },

);

plan tests => scalar @tests;

foreach my $test (@tests) {
    my @ret = FusionInventory::Agent::Task::Deploy::P2P::_computeIPToTest(
        undef, # $logger
        $test->{test}, 6 );
    cmp_deeply(\@ret, $test->{ret}, $test->{name});
}
