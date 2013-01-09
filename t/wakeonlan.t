#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::WakeOnLan;

my @tests = (
    '0024D66F813A',
    'A4BADBA5F5FA'
);

plan tests => scalar @tests * 2;

foreach my $test (@tests) {
    my $payload = FusionInventory::Agent::Task::WakeOnLan->_getPayload($test);
    my ($header, $values) = unpack('H12H192', $payload);
    is($header, 'ffffffffffff', "payload header for $test");
    is($values, lc($test) x 16, "payload values for $test");
}
