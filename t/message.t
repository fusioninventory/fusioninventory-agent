#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;

use FusionInventory::Agent::XML::Response;
use FusionInventory::Agent::Task::NetInventory;

my %messages = (
    message2 => {
        models => {
            196 => {
                ID   => 196,
                NAME => 4675719,
                WALK => {
                    ifaddr => {
                       VLAN => '0',
                       LINK => 'ifaddr',
                       OID => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    ifIndex => {
                        VLAN => '0',
                        LINK => 'ifIndex',
                        OID => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                },
                GET => {
                    name => {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    informations => {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
                }
            }
        }
    },
    message3 => {
        models => {
            196 => {
                ID   => 196,
                NAME => 4675719,
                WALK => {
                    ifaddr => {
                       VLAN => '0',
                       LINK => 'ifaddr',
                       OID => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    ifIndex => {
                        VLAN => '0',
                        LINK => 'ifIndex',
                        OID => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                },
                GET => {
                    name => {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    informations => {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
                }
            },
            197 => {
                ID   => 197,
                NAME => 4675720,
                WALK => {
                    ifaddr => {
                       VLAN => '0',
                       LINK => 'ifaddr',
                       OID => '.1.3.6.1.2.1.4.20.1.2',
                       OBJECT => 'ifaddr'
                    },
                    ifIndex => {
                        VLAN => '0',
                        LINK => 'ifIndex',
                        OID => '.1.3.6.1.2.1.2.2.1.1',
                        OBJECT => 'ifIndex'
                    }
                },
                GET => {
                    name => {
                        VLAN   => '0',
                        LINK   => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0',
                        OBJECT => 'name'
                    },
                    informations => {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        OBJECT => 'informations'
                    },
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
    is_deeply(
        FusionInventory::Agent::Task::NetInventory::_getIndexedModels($options->{MODEL}),
        $messages{$test}->{models},
        $test
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
