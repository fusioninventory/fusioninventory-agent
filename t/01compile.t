#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;


if (!eval "use Test::Compile;1") {
    eval "use Test::More skip_all => 'Missing Test::Compile';";
    exit 0
}


sub filter {
    return 0 if /REST/;
    if ($OSNAME ne 'MSWin32') {
        return 0 if /Syslog/;
        return 0 if /Win32/;
    }
    if (readlink $_) {
        return 0;
    }
    if (/(.*Task\/[^\/]+)\//) {
        return 0 if -l $1;
    }
    return 0 if /lib\/FusionInventory\/VMware/;
    return 1;
}

my @files = grep filter($_), all_pm_files('lib') ;

eval { require FusionInventory::Agent::SNMP; };
if ($EVAL_ERROR) {
    @files = grep  { ! /SNMP/ } @files;
}

all_pm_files_ok(@files);
