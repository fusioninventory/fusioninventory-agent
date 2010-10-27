#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use Test::Exception;

eval { require FusionInventory::Agent::SNMP; };

if ($EVAL_ERROR) {
    my $msg = 'Unable to load FusionInventory::Agent::SNMP';
    plan(skip_all => $msg);
}

plan tests => 7;

my $snmp;
throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new({
    });
} qr/^no hostname parameter/,
'instanciation: no hostname parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new({
        hostname => 'localhost',
        version  => 'foo'
    });
} qr/^invalid SNMP version/,
'instanciation: invalid version parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new({
        hostname => 'localhost',
        version  => 5
    });
} qr/^invalid SNMP version/,
'instanciation: invalid version parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new({
        hostname => 'localhost',
        version => 1
    });
} qr/^The community is not defined/,
'instanciation: undefined community';

lives_ok {
    $snmp = FusionInventory::Agent::SNMP->new({
        version   => 1,
        community => 'public',
        hostname  => 'localhost'
    });
} 'instanciation: OK';

ok(
    !defined $snmp->snmpGet(),
    'no OID'
);
ok(
    !defined $snmp->snmpGet({ oid => '1.3.6.1.2.1.1.3.0'}),
    'no server'
);
