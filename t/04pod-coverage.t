#!/usr/bin/perl
# $Id: pod-coverage.t 1580 2007-03-22 13:38:55Z guillomovitch $

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

use lib 't';
use FusionInventory::Test::Utils;

if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

eval { require Test::Pod::Coverage; };

if ($EVAL_ERROR) {
    my $msg = 'Test::Pod::Coverage required to check pod coverage';
    plan(skip_all => $msg);
}

Test::Pod::Coverage->import();

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

my @modules = grep { filter($_) } all_modules('lib');

plan tests => scalar @modules;

foreach my $module (@modules) {
    pod_coverage_ok(
        $module,
        {
            coverage_class => 'Pod::Coverage::CountParents',
            also_private => [ qw/doInventory isEnabled/ ],
        }
    );
}
