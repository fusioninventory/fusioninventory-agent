#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;


if (!eval "use Test::Compile;1") {
    eval "use Test::More skip_all => 'Missing Test::Compile';";
    exit 0
}



my @files = $OSNAME eq 'MSWin32' ?
    grep { ! /Syslog/ } all_pm_files('lib') :
    grep { ! /Win32/  } all_pm_files('lib') ;

eval { require FusionInventory::Agent::SNMP; };
if ($EVAL_ERROR) {
    @files = grep  { ! /SNMP/ } @files;
}

all_pm_files_ok(@files);
