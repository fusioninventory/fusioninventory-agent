#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Collect;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Fatal' ]
);

my $task = undef ;

my %params = ();

my $plan = 10;

plan tests => $plan;

lives_ok {
    $task = FusionInventory::Agent::Task::Collect->new(
        target => 'xxx',
        logger => $logger,
        config => {
            jobs => []
        }
    );
} "Collect object instanciation" ;
is( $task->{target}, 'xxx' );

throws_ok {
    FusionInventory::Agent::Task::Collect->run();
} qr/no target provided/, "Normal no target failure on run API call" ;

throws_ok {
    $task->run();
} qr/no target provided/, "Normal no target task failure on run method" ;

$params{target} = 'yyy';
throws_ok {
    $task->run(%params);
} qr/no jobs provided/, "Normal no job failure" ;

my $job = {};
push @{$task->{config}->{jobs}}, $job ;

throws_ok {
    $task->run(%params);
} qr/UUID key missing/, "Will skip job without UUID" ;

$job->{uuid} = 'zzz';
throws_ok {
    $task->run(%params);
} qr/function key missing/, "Will skip job without specified function" ;

$job->{function} = 'unknown collect function';
throws_ok {
    $task->run(%params);
} qr/Bad function/, "Will skip job with unknown function" ;

# We need to fake a target so runmethod can be called back in 'run' method
my $target = {};
bless $target, "Fake::Target";
$params{target} = $target;

my $returned_object = undef ;

$job->{function} = 'findFile';

lives_ok {
    $returned_object = $task->run(%params);
} "Normal run using 'findFile' known function" ;

is($returned_object, $task);

# Fake target class to just simulate needed 'send' method
package Fake::Target;

sub send {
}

1
