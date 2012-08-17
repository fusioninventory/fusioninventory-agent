#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);

use Test::More tests => 2;

my $help = `$EXECUTABLE_NAME fusioninventory-esx --help 2>&1`;
like($help, qr{vCenter/ESX/ESXi remote inventory from command}, '--help');

my $unknownHost = `$EXECUTABLE_NAME fusioninventory-esx --host unknowndevice --user a --password a --directory /tmp 2>&1`;
like($unknownHost, qr/500\s\S/, 'Bad hostname');
