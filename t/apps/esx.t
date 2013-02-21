#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::ESX;

use English qw(-no_match_vars);

use Test::More tests => 3;

my $help = `$EXECUTABLE_NAME bin/fusioninventory-esx --help 2>&1`;
like($help, qr{vCenter/ESX/ESXi remote inventory from command}, '--help');

my $unknownHost = `$EXECUTABLE_NAME bin/fusioninventory-esx --host unknowndevice --user a --password a --directory /tmp 2>&1`;
like($unknownHost, qr/500\s\S/, 'Bad hostname');

my $version = `$EXECUTABLE_NAME bin/fusioninventory-esx --version 2>&1`;
like($version, qr{fusioninventory-esx $FusionInventory::Agent::Task::ESX::VERSION}, '--version');

