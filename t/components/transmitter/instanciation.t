#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use FusionInventory::Agent::Transmitter;

plan tests => 3;

my $transmitter;

# instanciations tests

throws_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        ca_cert_file => '/no/such/file',
    );
} qr/^non-existing certificate file/,
'instanciation: invalid ca cert file';

throws_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new(
        ca_cert_dir => '/no/such/directory',
    );
} qr/^non-existing certificate directory/,
'instanciation: invalid ca cert directory';

lives_ok {
    $transmitter = FusionInventory::Agent::Transmitter->new();
} 'instanciation: http';
