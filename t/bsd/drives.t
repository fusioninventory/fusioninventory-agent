#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::BSD::Drives;
use Test::More;

my %df_tests = (
    'freebsd-8.1' => [
        {
            VOLUMN     => '/dev/ad4s1a',
            TOTAL      => '1447',
            FREE       => '965',
            TYPE       => '/',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1g',
            TOTAL      => '138968',
            FREE       => '12851',
            TYPE       => '/Donnees',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1e',
            TOTAL      => '495',
            FREE       => '397',
            TYPE       => '/tmp',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1f',
            TOTAL      => '19832',
            FREE       => '5118',
            TYPE       => '/usr',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1d',
            TOTAL      => '3880',
            FREE       => '2571',
            TYPE       => '/var',
            FILESYSTEM => 'ufs'
        }
    ]
);

plan tests => scalar keys %df_tests;

foreach my $test (keys %df_tests) {
    my $file = "resources/df/$test";
    my $results = FusionInventory::Agent::Task::Inventory::OS::BSD::Drives::_parseDf($file, '<');
    is_deeply($results, $hal_tests{$test}, $test);
}
