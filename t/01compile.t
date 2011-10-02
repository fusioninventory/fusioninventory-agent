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

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/fake/unix';
} else {
    push @INC, 't/fake/windows';
}

# blacklist additional tasks that may be installed
sub filter {
    return
        $_ !~ m{FusionInventory/Agent/Task} ||
        $_ =~ m{FusionInventory/Agent/Task/(Inventory|WakeOnLan)};
}

# exclude linked modules
my @files = grep { filter($_) } all_pm_files('lib');

eval { require FusionInventory::Agent::SNMP; };
if ($EVAL_ERROR) {
    @files = grep  { ! /SNMP/ } @files;
}

all_pm_files_ok(@files);
