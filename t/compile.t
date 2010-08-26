#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use Test::Compile;

my @files = $OSNAME eq 'MSWin32' ?
    grep { ! /Syslog/ } all_pm_files('lib') :
    grep { ! /Win32/  } all_pm_files('lib') ;

all_pm_files_ok(@files);
