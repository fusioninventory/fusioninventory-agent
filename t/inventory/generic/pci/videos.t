#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Generic::PCI::Videos;

my %tests = (
    'dell-xt2' => [
        {
            NAME    => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            CHIPSET => 'VGA compatible controller'
        },
        {
            NAME    => 'Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller',
            CHIPSET => 'Display controller'
        }
      ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @videos = FusionInventory::Agent::Task::Inventory::Input::Generic::PCI::Videos::_getVideos(file => $file);
    cmp_deeply(\@videos, $tests{$test}, $test);
}
