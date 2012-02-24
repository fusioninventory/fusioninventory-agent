#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

eval { require Test::Vars; };

if ($EVAL_ERROR) {
    plan(skip_all => 'Test::Vars required to validate the code');
}

Test::Vars::all_vars_ok(ignore_vars => { '$i' => 1 });

