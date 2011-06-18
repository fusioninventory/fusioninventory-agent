#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use Test::Exception;

use FusionInventory::Agent::XML::Response;

eval { require FusionInventory::Agent::SNMP; };

if ($EVAL_ERROR) {
    my $msg = 'Unable to load FusionInventory::Agent::SNMP';
    plan(skip_all => $msg);
}

plan tests => 9;

my $snmp;
throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new();
} qr/^no hostname parameter/,
'instanciation: no hostname parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new(
        hostname => 'localhost',
        version  => 'foo'
    );
} qr/^invalid SNMP version/,
'instanciation: invalid version parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new(
        hostname => 'localhost',
        version  => 5
    );
} qr/^invalid SNMP version/,
'instanciation: invalid version parameter';

throws_ok {
    $snmp = FusionInventory::Agent::SNMP->new(
        hostname => 'localhost',
        version => 1
    );
} qr/[Cc]ommunity (is )?not defined/,
'instanciation: undefined community';

lives_ok {
    $snmp = FusionInventory::Agent::SNMP->new(
        version   => 1,
        community => 'public',
        hostname  => 'localhost'
    );
} 'instanciation: OK';

ok(
    !defined $snmp->get(),
    'no OID'
);

ok(
    !defined $snmp->walk(),
    'no first OID'
);

SKIP: {
skip 'live SNMP test disabled', 2 unless $ENV{TEST_LIVE_SNMP};

is(
    $snmp->get('1.3.6.1.2.1.1.9.1.3.3'),
    'The SNMP Management Architecture MIB.',
    'simple value query'
);

is_deeply(
    $snmp->walk('1.3.6.1.2.1.1.9.1.3'),
    {
        '1.3.6.1.2.1.1.9.1.3.1' => 'The MIB for Message Processing and Dispatching.',
        '1.3.6.1.2.1.1.9.1.3.2' => 'The MIB for Message Processing and Dispatching.',
        '1.3.6.1.2.1.1.9.1.3.3' => 'The SNMP Management Architecture MIB.',
        '1.3.6.1.2.1.1.9.1.3.4' => 'The MIB module for SNMPv2 entities',
        '1.3.6.1.2.1.1.9.1.3.5' => 'The MIB module for managing TCP implementations',
        '1.3.6.1.2.1.1.9.1.3.6' => 'The MIB module for managing IP and ICMP implementations',
        '1.3.6.1.2.1.1.9.1.3.7' => 'The MIB module for managing UDP implementations',
        '1.3.6.1.2.1.1.9.1.3.8' => 'View-based Access Control Model for SNMP.'
    },
    'multiple value query'
);
}
