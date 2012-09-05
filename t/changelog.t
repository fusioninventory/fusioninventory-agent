#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);
use DateTime::Format::Mail;

plan(skip_all => 'Author test, set $ENV{TEST_AUTHOR} to a true value to run')
    if !$ENV{TEST_AUTHOR};

plan tests => 1;

open CHANGES, 'Changes' or die;

# Skip the 2 first lines;
<CHANGES>;
<CHANGES>;

my $line = <CHANGES>;

$line =~ /^[\d\.]+\s+(\S.*)/;
ok(DateTime::Format::Mail->parse_datetime($1), "RFC822 date format (date -R)");


