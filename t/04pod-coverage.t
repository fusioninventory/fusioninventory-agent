#!/usr/bin/perl
# $Id: pod-coverage.t 1580 2007-03-22 13:38:55Z guillomovitch $

use strict;
use warnings;
use Test::More;
use English qw(-no_match_vars);

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

my @modules = $OSNAME eq 'MSWin32' ?
    grep { ! /Syslog/ } all_modules('lib') :
    grep { ! /(Win32|Registry)/  } all_modules('lib') ;

plan tests => scalar @modules;

foreach my $module (@modules) {
    pod_coverage_ok(
        $module,
        {
            coverage_class => 'Pod::Coverage::CountParents',
            also_private => [ qw/doInventory isInventoryEnabled/ ],
        }
    );
}
