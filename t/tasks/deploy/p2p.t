#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Deploy::P2P;

my @tests = (
    {
        name    => 'Ignore',
        address => { ip  => '127.0.0.1', mask => '255.0.0.0' },
        result  => [ ]
    },
    {
        name    => '192.168.5.5',
        address => { ip => '192.168.5.5', mask => '255.255.255.0' },
        result  => [
          '192.168.5.2',
          '192.168.5.3',
          '192.168.5.4',
          '192.168.5.5',
          '192.168.5.6',
          '192.168.5.7'
        ]
    },
    {
        name    => '10.5.6.200',
        address => { ip => '10.5.6.200', mask => '255.255.250.0' },
        result  => [
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
    my @peers = FusionInventory::Agent::Task::Deploy::P2P::_getPotentialPeers(
        undef, # $logger
        $test->{address},
        6
    );
    cmp_deeply(\@peers, $test->{result}, $test->{name});
}
