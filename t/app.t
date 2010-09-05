#!/usr/bin/perl -w

use strict;

use English qw(-no_match_vars);

use Test::More tests => 1;

my $help = `$EXECUTABLE_NAME fusioninventory-agent --devlib --help 2>&1`;
like($help, qr/See man fusioninventory-agent/, '--help');
