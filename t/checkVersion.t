#!/usr/bin/perl -w
use strict;
use File::Glob;
use Test::More;
use Data::Dumper;
use File::Basename;


my @taskPm;
foreach (File::Glob::bsd_glob('lib/FusionInventory/Agent/Task/*.pm')) {
    next if basename($_) eq 'Base.pm';
    push @taskPm, $_;
}


plan tests => 1 + @taskPm;
use_ok('FusionInventory::Agent::Tools');

foreach (@taskPm) {
    ok (getVersionFromTaskModuleFile($_), 'getVersionFromTaskModuleFile()')
}
