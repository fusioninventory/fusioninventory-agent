#!/usr/bin/perl

use strict;
use warnings;

use Compress::Zlib;
use English qw(-no_match_vars);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Transmitter;

plan tests => 2;

my $transmitter = FusionInventory::Agent::Transmitter->new(
);

my $data = "this is a test";
is(
    $transmitter->_uncompressNative($transmitter->_compressNative($data)),
    $data,
    'round-trip compression with Compress::Zlib'
);

SKIP: {
    skip "gzip is not available under Windows", 1 if $OSNAME eq 'MSWin32';
    is(
        $transmitter->_uncompressGzip($transmitter->_compressGzip($data)),
        $data,
        'round-trip compression with Gzip'
    );
}
