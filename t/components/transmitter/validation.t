#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Transmitter;


my @tests = (
    [ 'localhost', 'O=domain.tld, CN=localhost/emailAddress=a@domain.tld' ],
    [ 'localhost', 'O=domain.tld, CN=localhost'                               ],
    [ 'localhost', 'O=domain.tld, CN=*/emailAddress=a@domain.tld' ],
    [ 'localhost', 'O=domain.tld, CN=*' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host.domain.tld/emailAddress=a@domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host.domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=*.domain.tld/emailAddress=a@domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=*.domain.tld' ],
);

plan tests => scalar @tests;

foreach my $test (@tests) {
    my $pattern = FusionInventory::Agent::Transmitter::_getCertificateRegexp($test->[0]);
    ok($test->[1] =~ $pattern);
}
