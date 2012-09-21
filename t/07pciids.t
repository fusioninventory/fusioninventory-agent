#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

ok (-f 'share/pci.ids', 'share/pci.ids exists');
