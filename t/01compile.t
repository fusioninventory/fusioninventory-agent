#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;

eval {
    require Test::Compile;
    Test::Compile->import();
};
if ($EVAL_ERROR) {
    my $msg = 'Test::Compile required';
    plan(skip_all => $msg);
}

if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

sub filter {
    return 0 if /REST/;
    return 0 if /lib\/FusionInventory\/VMware/;
    return 0 if readlink $_;
    if (/(.*Task\/[^\/]+)\//) {
        return 0 if -l $1;
    }
    return 1;
}

my @files = grep filter($_), all_pm_files('lib') ;

eval { require FusionInventory::Agent::SNMP; };
if ($EVAL_ERROR) {
    @files = grep  { ! /SNMP/ } @files;
}

all_pm_files_ok(@files);
