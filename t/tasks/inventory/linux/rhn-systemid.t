#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Linux;

my %tests = (
    'ID-1232324425' => 'ID-123232425'
);
plan tests => (scalar keys %tests) + 1;

foreach my $test (keys %tests) {
    my $file = "resources/linux/rhn-systemid/$test";
    my $rhenSysteId = FusionInventory::Agent::Task::Inventory::Linux::_getRHNSystemId($file);
    ok($rhenSysteId, $tests{$test});
}
