#!/usr/bin/perl -w

use strict;

use Test::More tests => 1;

my $help = `./fusioninventory-agent --devlib --help 2>&1`;
like($help, qr/See man fusioninventory-agent/, '--help');
