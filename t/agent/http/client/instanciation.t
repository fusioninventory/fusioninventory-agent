#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use FusionInventory::Agent::HTTP::Client;

plan tests => 2;

my $client;

# instanciations tests

throws_ok {
    $client = FusionInventory::Agent::HTTP::Client->new(
        ca_cert_path => '/no/such/file',
    );
} qr/^non-existing certificate path/,
'instanciation: invalid ca cert path';

lives_ok {
    $client = FusionInventory::Agent::HTTP::Client->new();
} 'instanciation: http';
