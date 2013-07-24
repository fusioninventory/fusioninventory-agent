#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Solaris::Memory;

my %tests = (
    sample1 => [ _gen(4,  'NUMSLOTS', { CAPACITY => '1000' }) ],
    sample2 => [ _gen(32, 'NUMSLOTS', { CAPACITY => '1024' }) ],
    sample3 => [ _gen(16, 'NUMSLOTS', { TYPE     => 'DDR2' }) ],
    sample4 => [ _gen(8,  'NUMSLOTS', { TYPE     => 'DDR'  }) ],
    sample5 => [ _gen(2,  'NUMSLOTS', { TYPE     => 'DRAM' }) ],
    sample6 => [ _gen(8,  'NUMSLOTS', { CAPACITY => '512'  }) ],
    sample7 => [ _gen(1,  'NUMSLOTS', { CAPACITY => '2000' }) ],
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/solaris/prtdiag/$test";
    my @results =
      FusionInventory::Agent::Task::Inventory::Solaris::Memory::_getMemoriesPrtdiag(file => $file);
    cmp_deeply(
        \@results,
        $tests{$test},
        "prtdiag parsing: $test"
    );
}

sub _gen {
    my ($count, $key, $base) = @_;

    my @objects;
    foreach my $i (1 .. $count) {
        my $object = _clone($base);
        $object->{$key} = $i - 1;
        push @objects, $object;
    }

    return @objects;
}

sub _clone {
    my ($base) = @_;

    my $object;
    foreach my $key (keys %$base) {
        $object->{$key} = $base->{$key};
    }

    return $object;
}
