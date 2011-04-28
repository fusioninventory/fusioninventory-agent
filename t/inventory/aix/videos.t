#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

my %tests = (
    sample1 => [
        {
            NAME => 'lai0',
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/lsdev/$test.adapter";
    my @videos = FusionInventory::Agent::Task::Inventory::OS::AIX::Videos::_getVideos(file => $file);
    is_deeply(\@videos, $tests{$test}, "videos: $test");
}
