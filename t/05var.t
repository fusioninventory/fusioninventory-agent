#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

eval { require Test::Vars; };
plan(skip_all => 'Test::Vars required') if $EVAL_ERROR;

Test::Vars->import();

all_vars_ok(
    ignore_vars => { '%params' => 1, '$class' => 1 }
);

