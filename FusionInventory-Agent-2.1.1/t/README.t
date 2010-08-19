#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

my $help = `./fusioninventory-agent --devlib --help 2>&1`;
ok(-f 'README', 'README exists');
ok(-f 'README.html', 'README.html exists');
