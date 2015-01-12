#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Deploy;

my %tests = (
    deploy1 => qr/^missing files list/,
    deploy2 => qr/^invalid server answer/,
    deploy3 => qr/^invalid server answer/,
    deploy4 => qr/^missing key 'mirrors' in file \S+/,
    deploy5 => qr/^invalid actions list format/,
    deploy6 => qr/^missing key 'uuid' in job #1/,
    deploy7 => qr/^missing key 'p2p' in file \S+/
);

plan tests => scalar keys %tests;

my $task = FusionInventory::Agent::Task::Deploy->new();

foreach my $test (keys %tests) {
    my $file = "resources/messages/json/$test.json";
    my $string = getAllLines(file => $file);
    my $struct = eval {decode_json($string)};

    throws_ok {
        $task->getConfiguration(
            spec => { config => $struct }
        );
    } $tests{$test},
    $file;
}
