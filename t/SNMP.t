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

my %messages = (
    message2 => {
        type => 'SNMPQUERY',
        auths => [
            {
                'PRIVPROTOCOL' => '',
                'AUTHPROTOCOL' => '',
                'ID' => '1',
                'USERNAME' => '',
                'AUTHPASSPHRASE' => '',
                'VERSION' => '1',
                'COMMUNITY' => 'public',
                'PRIVPASSPHRASE' => ''
            },
        ],
    },
    message3 => {
        type => 'NETDISCOVERY',
        auths => [
            {
                'PRIVPROTOCOL' => '',
                'AUTHPROTOCOL' => '',
                'ID' => '1',
                'USERNAME' => '',
                'AUTHPASSPHRASE' => '',
                'VERSION' => '1',
                'COMMUNITY' => 'public',
                'PRIVPASSPHRASE' => ''
            },
            {
                'PRIVPROTOCOL' => '',
                'AUTHPROTOCOL' => '',
                'ID' => '2',
                'USERNAME' => '',
                'AUTHPASSPHRASE' => '',
                'VERSION' => '2c',
                'COMMUNITY' => 'public',
                'PRIVPASSPHRASE' => ''
            }
        ],
    },
);

plan tests => 9 + (scalar keys %messages);

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
    !defined $snmp->snmpWalk(),
    'no first OID'
);

foreach my $test (keys %messages) {
    my $file = "resources/xml/response/$test.xml";
    my $message = FusionInventory::Agent::XML::Response->new({
        content => slurp($file)
    });
    my $options = $message->getOptionsInfoByName($messages{$test}->{type});
    is_deeply(
        FusionInventory::Agent::SNMP->getAuthList($options),
        $messages{$test}->{auths},
        $test
    );
}

SKIP: {
skip 'live SNMP test disabled', 2 unless $ENV{TEST_LIVE_SNMP};

is(
    $snmp->snmpGet({ oid => '1.3.6.1.2.1.1.9.1.3.3'}),
    'The SNMP Management Architecture MIB.',
    'simple value query'
);

is_deeply(
    $snmp->snmpWalk({ oid_start => '1.3.6.1.2.1.1.9.1.3'}),
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

sub slurp {
    my($file) = @_;

    my $handler;
    return unless open $handler, '<', $file;
    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $content = <$handler>;
    close $handler;
    return $content;
}
