#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use File::Basename;
use FusionInventory::Agent::Task::Inventory::OS::Linux;

my @tests = glob("resources/rhn-systemid/??*");
plan tests => int (@tests);

foreach my $file (@tests) {
    my $result = basename($file);
    my $rhenSysteId = FusionInventory::Agent::Task::Inventory::OS::Linux::_getRHNSystemId ($file);
    ok($rhenSysteId, $_);
}
