#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

eval { require Test::Perl::Critic; };
plan(skip_all => 'Test::Perl::Critic required') if $EVAL_ERROR;

my $config = File::Spec->catfile('t', 'perlcriticrc');
Test::Perl::Critic->import(-profile => $config);

all_critic_ok();

