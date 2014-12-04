#!/usr/bin/perl

use strict;
use warnings;

use File::Temp qw(tempdir);
use Test::More;

use FusionInventory::Agent::Task::Inventory;
use FusionInventory::Agent::Tools;

plan tests => 2;

my $task = FusionInventory::Agent::Task::Inventory->new();

my @modules = $task->getModules();
ok(@modules != 0, 'modules list is not empty');
ok(
    (all { $_ =~ /^FusionInventory::Agent::Task::Inventory::/ } @modules),
    'modules list only contains inventory modules'
);
