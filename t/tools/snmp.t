#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::SNMP;

plan tests => 6;

my $oid = '0.1.2.3.4.5.6.7.8.9';
is(getElement($oid, 0),        0, 'getElement with index 0');
is(getElement($oid, -1),       9, 'getElement with index -1');
is(getLastElement($oid),       9, 'getLastElement');
is(getNextToLastElement($oid), 8, 'getNextToLastElement');
is_deeply(
    [ getElements($oid, 0, 3) ],
    [ qw/0 1 2 3/ ],
    'getElements with index 0 to 3'
);
is_deeply(
    [ getElements($oid, -4, -1) ],
    [ qw/6 7 8 9/ ],
    'getElements with index -4 to -1'
);
