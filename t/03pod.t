#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

eval { require Test::Pod; };

if ($EVAL_ERROR) {
    my $msg = 'Test::Pod required to check pod';
    plan(skip_all => $msg);
}

Test::Pod->import();
all_pod_files_ok();
