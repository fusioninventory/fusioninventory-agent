#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

eval { require Test::Pod; };
plan(skip_all => 'Test::Pod required') if $EVAL_ERROR;

Test::Pod->import();

all_pod_files_ok();
