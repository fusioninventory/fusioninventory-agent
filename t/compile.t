#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Compile;

all_pm_files_ok(
    grep { ! /Win32/ } all_pm_files('lib')
);
