#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);
use UNIVERSAL::require;

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

DateTime::Format::Mail->require();
plan(skip_all => 'DateTime::Format::Mail required') if $EVAL_ERROR;

plan tests => 1;

open CHANGES, 'Changes' or die;

# Skip the 2 first lines;
<CHANGES>;
<CHANGES>;

my $line = <CHANGES>;

$line =~ /^[\d\.]+\s+(\S.*)/;
ok($1 && DateTime::Format::Mail->parse_datetime($1), "RFC822 date format (date -R)");
