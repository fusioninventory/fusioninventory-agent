#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

eval { require Test::Pod::Spelling::CommonMistakes; };

if ($EVAL_ERROR) {
    plan(
        skip_all =>
        'Test::Pod::Spelling::CommonMistakes required to check speeling'
    );
}

Test::Pod::Spelling::CommonMistakes::all_pod_files_ok();
