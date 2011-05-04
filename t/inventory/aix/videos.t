#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

my %tests = (
    'aix-5.3' => [
        {
            NAME => 'lai0',
        }
    ],
    'aix-6.1' => []
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/aix/lsdev/$test-adapter";
    my @videos = FusionInventory::Agent::Task::Inventory::OS::AIX::Videos::_getVideos(file => $file);
    is_deeply(\@videos, $tests{$test}, "videos: $test");
}
