#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Deep qw(cmp_deeply bag);
use Test::More;

use FusionInventory::Agent::Task::NetInventory;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::XML::Response;

my %messages = (
    message2 => {
        models => {
            196 => {
                ID   => 196,
                NAME => 4675719,
                WALK => bag(
                    {
                       VLAN   => '0',
                       LINK   => 'ifaddr',
                       OID    => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifIndex',
                        OID    => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                ),
                GET => bag(
                    {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
                ),
                oids => {
                    name         => '.1.3.6.1.2.1.1.5.0',
                    ifIndex      => '.1.3.6.1.2.1.2.2.1.1',
                    ifaddr       => '.1.3.6.1.2.1.4.20.1.2',
                    informations => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                }
            }
        }
    },
    message3 => {
        models => {
            196 => {
                ID   => 196,
                NAME => 4675719,
                WALK => bag(
                    {
                       VLAN   => '0',
                       LINK   => 'ifaddr',
                       OID    => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifIndex',
                        OID    => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                ),
                GET => bag(
                    {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
                ),
                oids => {
                    name         => '.1.3.6.1.2.1.1.5.0',
                    ifIndex      => '.1.3.6.1.2.1.2.2.1.1',
                    ifaddr       => '.1.3.6.1.2.1.4.20.1.2',
                    informations => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                }
            },
            197 => {
                ID   => 197,
                NAME => 4675720,
                WALK => bag(
                    {
                       VLAN   => '0',
                       LINK   => 'ifaddr',
                       OID    => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifIndex',
                        OID    => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                ),
                GET => bag(
                    {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
                ),
                oids => {
                    name         => '.1.3.6.1.2.1.1.5.0',
                    ifIndex      => '.1.3.6.1.2.1.2.2.1.1',
                    ifaddr       => '.1.3.6.1.2.1.4.20.1.2',
                    informations => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                }
            },

        }
    }
);

plan tests => scalar keys %messages;

foreach my $test (keys %messages) {
    my $file = "resources/messages/$test.xml";
    my $message = FusionInventory::Agent::XML::Response->new(
        content => slurp($file)
    );
    my $options = $message->getOptionsInfoByName('SNMPQUERY');
    cmp_deeply(
        FusionInventory::Agent::Task::NetInventory::_getIndexedModels($options->{MODEL}),
        $messages{$test}->{models},
        $test
    );
}
