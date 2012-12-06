#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

ok (-f 'share/pci.ids', 'share/pci.ids exists');
ok (-f 'share/usb.ids', 'share/usb.ids exists');
