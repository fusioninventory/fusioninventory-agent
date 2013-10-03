#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Cwd;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use Test::More;
use Test::MockModule;

# use mock modules for non-available ones
if ($OSNAME eq 'MSWin32') {
    push @INC, 't/lib/fake/unix';
} else {
    push @INC, 't/lib/fake/windows';
}


FusionInventory::Agent::Task::Collect->require();


plan tests => 2;


my @result;

@result = FusionInventory::Agent::Task::Collect::_findFile(
    dir => getcwd(),
    recursive => 1
);
ok(int(@result) == 50, "_findFile() recursive=1 reach the limit");

@result = FusionInventory::Agent::Task::Collect::_findFile(
    dir   => getcwd(),
    limit => 60,
    recursive => 1
);

ok(int(@result) == 60, "_findFile() limit=60");
