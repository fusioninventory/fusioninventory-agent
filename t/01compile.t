#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;

use lib 't';
use FusionInventory::Test::Utils;

eval {
    require Test::Compile;
    Test::Compile->import();
};
if ($EVAL_ERROR) {
    my $msg = 'Test::Compile required';
    plan(skip_all => $msg);
}

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

# exclude linked modules
my @files = grep { filter($_) } all_pm_files('lib');

all_pm_files_ok(@files);
