#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use File::Temp;
use Test::More;

use FusionInventory::Agent::Config;

my %config = (
    'sample1' => {
        'no-task' => ['snmpquery', 'wakeonlan', 'inventory'],
        'no-category' => ['software']
    },
    'sample2' => {
        'no-task' => [],
        'no-category' => ['printer', 'software']
    },
    'sample3' => {
        'no-task' => [],
        'no-category' => []
    }

);

plan tests => (scalar keys %config) * 2;

foreach my $test (keys %config) {
    my $c = FusionInventory::Agent::Config->new(options => {
        'conf-file' => "t/config/$test/agent.cfg"
    });

    is_deeply($c->{'no-task'}, $config{$test}->{'no-task'}, "no-task");
    is_deeply($c->{'no-category'}, $config{$test}->{'no-category'}, "no-category");
}

