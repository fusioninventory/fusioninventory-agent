#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Compile;

all_pm_files_ok(all_pm_files('lib'));
