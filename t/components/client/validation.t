#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::HTTP::Client;

my @ok = (
    [ 'host', 'O=domain.tld, CN=host/emailAddress=a@domain.tld' ],
    [ 'host', 'O=domain.tld, CN=host' ],
    [ 'host', 'O=domain.tld, CN=*/emailAddress=a@domain.tld' ],
    [ 'host', 'O=domain.tld, CN=*' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host.domain.tld/emailAddress=a@domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host.domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=*.domain.tld/emailAddress=a@domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=*.domain.tld' ],
);

my @nok = (
    [ 'host', 'O=domain.tld, CN=host.domain.tld/emailAddress=a@domain.tld' ],
    [ 'host', 'O=domain.tld, CN=host.domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host/emailAddress=a@domain.tld' ],
    [ 'host.domain.tld', 'O=domain.tld, CN=host' ],
);

plan tests => scalar @ok + scalar @nok;

foreach my $ok (@ok) {
    my $pattern = FusionInventory::Agent::HTTP::Client::_getCertificatePattern($ok->[0]);
    ok($ok->[1] =~ /$pattern/);
}

foreach my $nok (@nok) {
    my $pattern = FusionInventory::Agent::HTTP::Client::_getCertificatePattern($nok->[0]);
    ok($nok->[1] !~ /$pattern/);
}
