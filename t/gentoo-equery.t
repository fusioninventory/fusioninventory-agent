#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::Gentoo;
use Test::More;
use File::Basename;

my %result = (
    '0.3.0' => 1
);

my @test = glob("resources/gentoo/equery/*");
plan tests => @test - 1;

foreach my $file (@test) {
    my $test = basename($file);
    next if $test eq 'README';
    my $r = FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::Gentoo::_equeryNeedsWildcard($file, '<');
    is($result{$test}, $r, "version $test");
}
