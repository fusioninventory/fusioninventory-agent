#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Deep qw(cmp_deeply bag);
use Test::More;

use FusionInventory::Agent::Task::NetInventory;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Message::Inbound;

my %messages = (
    message2 => {
        pid     => '1280265498/024',
        timeout => undef,
        threads => 4,
        devices => [
            {
                'id'           => '72',
                'type'         => 'PRINTER',
                'ip'           => '192.168.0.151',
                'modelsnmp_id' => '196',
                'authsnmp_id'  => '1'
            }
        ],
        credentials => [
            {
                'id'             => '1',
                'authprotocol'   => '',
                'privprotocol'   => '',
                'authpassphrase' => '',
                'community'      => 'public',
                'username'       => '',
                'privpassphrase' => '',
                'version'        => '1'
            }
        ],
        models => [
            {
                id   => 196,
                name => 4675719,
                oids => {
                    name         => '.1.3.6.1.2.1.1.5.0',
                    ifaddr       => '.1.3.6.1.2.1.4.20.1.2',
                    ifIndex      => '.1.3.6.1.2.1.2.2.1.1',
                    informations => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                }
            }
        ]
    },
    message3 => {
        'pid'     => '1280265498/024',
        'timeout' => undef,
        'threads' => '4',
        'credentials' => [
            {
                'id'             => '1',
                'authpassphrase' => '',
                'community'      => 'public',
                'privpassphrase' => '',
                'privprotocol'   => '',
                'authprotocol'   => '',
                'username'       => '',
                'version'        => '1'
            }
        ],
        'devices' => [
            {
                'authsnmp_id'  => '1',
                'id'           => '72',
                'type'         => 'PRINTER',
                'modelsnmp_id' => '196',
                'ip'           => '192.168.0.151'
            }
        ],
        'models' => [
            {
                'id'   => '196',
                'name' => '4675719',
                'oids' => {
                    'name'         => '.1.3.6.1.2.1.1.5.0',
                    'ifaddr'       => '.1.3.6.1.2.1.4.20.1.2',
                    'ifIndex'      => '.1.3.6.1.2.1.2.2.1.1',
                    'informations' => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0'
                },
            },
            {
                'id'   => '197',
                'name' => '4675720',
                'oids' => {
                    'name'         => '.1.3.6.1.2.1.1.5.0',
                    'ifaddr'       => '.1.3.6.1.2.1.4.20.1.2',
                    'ifIndex'      => '.1.3.6.1.2.1.2.2.1.1',
                    'informations' => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0'
                }
            }
        ]
    }
);

plan tests => scalar keys %messages;

my $task = FusionInventory::Agent::Task::NetInventory->new();

foreach my $test (keys %messages) {
    my $file = "resources/messages/$test.xml";
    my $message = FusionInventory::Agent::Message::Inbound->new(
        content => slurp($file)
    );
    my %configuration = $task->getConfiguration(response => $message);
    cmp_deeply(
        \%configuration,
        $messages{$test},
        $test
    );
}
