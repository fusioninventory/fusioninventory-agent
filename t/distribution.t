#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Find::Rule;
use English qw(-no_match_vars);

my @files =
    File::Find::Rule->file()->name('*.pm')->in('lib');

my @modules;
foreach my $file (@files) {
    my (undef, $dir, $file) = File::Spec->splitpath($file);
    my @dirs = File::Spec->splitdir($dir);
    push @modules, join '::', @dirs, File::Basename::basename($file, '.pm');
}

plan tests => scalar @modules;

foreach my $module (@modules) {
    use_ok($module);
}
