#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw(first);
use Test::Deep qw(cmp_deeply);
use Test::More;

use FusionInventory::Agent::Message::Inbound;
use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Agent::Tools;

my %tests = (
    prolog1 => {
        timeout => undef,
        workers => '10',
        pid     => '1280265592/024',
        blocks    => [
            {
                id     => '1',
                spec   => '192.168.0.1-192.168.0.254',
                entity => '15',
            }

        ],
        credentials => [
            {
                privpassword => '',
                authpassword => '',
                username     => '',
                id           => '1',
                privprotocol => '',
                authprotocol => '',
                community    => 'public',
                version      => '1'
            },
            {
                version      => '2c',
                community    => 'public',
                authprotocol => '',
                privprotocol => '',
                id           => '2',
                username     => '',
                authpassword => '',
                privpassword => ''
            }

        ],
    },
);

plan tests => scalar keys %tests;

my $task = FusionInventory::Agent::Task::NetDiscovery->new();

foreach my $test (keys %tests) {
    my $file = "resources/messages/xml/$test.xml";
    my $string = getAllLines(file => $file);
    my $prolog = FusionInventory::Agent::Message::Inbound->new(
        content => $string
    )->getContent();
    my $option = first { $_->{NAME} eq 'NETDISCOVERY' } @{$prolog->{OPTION}};

    my %config = $task->getConfiguration(spec => { config => $option });
    cmp_deeply(\%config, $tests{$test}, "$test parsing");
}
