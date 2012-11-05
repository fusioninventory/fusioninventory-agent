#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use UNIVERSAL::require;

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

plan(skip_all => 'Test::Perl::Critic required')
    unless Test::Perl::Critic->require();

my $config = File::Spec->catfile('t', 'perlcriticrc');
Test::Perl::Critic->import(-profile => $config);

all_critic_ok();

