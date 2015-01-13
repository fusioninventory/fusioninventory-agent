#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(first);
use Test::Deep qw(cmp_deeply);
use Test::More;

use FusionInventory::Agent::Message::Inbound;
use FusionInventory::Agent::Task::NetInventory;
use FusionInventory::Agent::Tools;

my %tests = (
    prolog2 => {
        'timeout' => undef,
        'threads' => '4',
        'pid'     => '1280265498/024',
        'jobs'    => [
            {
                'id'           => '72',
                'type'         => 'PRINTER',
                'host'         => '192.168.0.151',
                'community'    => 'public',
                'version'      => '1',
            }
        ]
    },
    prolog3 => {
        'threads' => '4',
        'timeout' => undef,
        'pid'     => '1280265498/024',
        'jobs'    => [
            {
                'id'           => '72',
                'type'         => 'PRINTER',
                'host'         => '192.168.0.151',
                'community'    => 'public',
                'version'      => '1',
            }
        ]
    },
    prolog4 => {
        'timeout' => undef,
        'threads' => '4',
        'pid'     => '1280265498/024',
        'jobs'    => [
            {
                'id'           => '72',
                'type'         => 'PRINTER',
                'host'         => '192.168.0.151',
                'community'    => 'public',
                'version'      => '1',
            }
        ]
    }
);

plan tests => scalar keys %tests;

my $task = FusionInventory::Agent::Task::NetInventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/messages/xml/$test.xml";
    my $string = getAllLines(file => $file);
    my $prolog = FusionInventory::Agent::Message::Inbound->new(
        content => $string
    )->getContent();
    my $option = first { $_->{NAME} eq 'SNMPQUERY' } @{$prolog->{OPTION}};

    my %config = $task->getConfiguration(spec => { config => $option });
    cmp_deeply(\%config, $tests{$test}, "$test parsing");
}
