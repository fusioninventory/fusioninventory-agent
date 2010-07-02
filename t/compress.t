#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use FusionInventory::Logger;
use FusionInventory::Compress;

plan tests => 1;

my $data = "this is a test";
my $compress = FusionInventory::Compress->new({
    logger => FusionInventory::Logger->new()
});

is(
    $compress->_uncompressGzip($compress->_compressGzip($data)),
    $data,
    'round-trip compression'
);
