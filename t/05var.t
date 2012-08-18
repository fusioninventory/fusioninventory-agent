#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use UNIVERSAL::require;

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

plan(skip_all => 'Test::Vars required')
    unless Test::Vars->require();

Test::Vars->import();

all_vars_ok(
    ignore_vars => {
        '%params' => 1,
        '$class'  => 1,
        '$walks'  => 1, # FusionInventory::Agent::Task::NetInventory
        '$device' => 1, # FusionInventory::Agent::Manufacturer
        '$oid'    => 1  # FusionInventory::Agent::Manufacturer
    }

);

