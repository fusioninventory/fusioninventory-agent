#!/usr/bin/perl

use strict;
use warnings;

use File::Temp qw(tempdir);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Controller::Local;
use FusionInventory::Agent::Task::Inventory;
use FusionInventory::Agent::Tools;

plan tests => 3;

my $task;

lives_ok {
    $task = FusionInventory::Agent::Task::Inventory->new(
        target => FusionInventory::Agent::Controller::Local->new(
            path => tempdir(),
            basevardir => tempdir()
        ),
    );
} 'instanciation: ok';

my @modules = $task->getModules();
ok(@modules != 0, 'modules list is not empty');
ok(
    (all { $_ =~ /^FusionInventory::Agent::Task::Inventory::/ } @modules),
    'modules list only contains inventory modules'
);
