#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory;
use Test::More tests => 2;

my %tests = (
        'hppa-1' => 1920,
        'ia64-1' => 8192 
);

foreach (keys %tests) {
    open F, "<resources/hpux/memory/cstm/$_" or warn;
    my @list_mem = <F>;
    close F;

    my $t = FusionInventory::Agent::Task::Inventory::OS::HPUX::Memory::_parseMemory(\@list_mem);
    ok($tests{$_} eq $t, $_);
}
