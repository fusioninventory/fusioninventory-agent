#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Find;
use English qw(-no_match_vars);

use lib 'lib';

my @files;

find ( sub {
        push @files, $File::Find::name if /\.pm$/;
    }, 'lib');

if ($OSNAME ne 'MSWin32') {
    # exclude windows-specific modules
    @files = grep { ! /Win32/ } @files
}

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
