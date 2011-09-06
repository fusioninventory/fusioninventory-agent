#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::HPUX::Networks;

my %lanadmin_tests = (
    'hpux1-0' => {
        'Outbound Discards' => '0',
        'PPA Number' => '0',
        'Outbound Octets' => '1880378407',
        'Internal MAC Receive Errors' => '0',
        'Inbound Unicast Packets' => '901741518',
        'Specific' => '655367',
        'Late Collisions' => '0',
        'Outbound Queue Length' => '0',
        'Outbound Errors' => '0',
        'Alignment Errors' => '0',
        'Single Collision Frames' => '0',
        'FCS Errors' => '0',
        'Last Change' => '287',
        'Administration Status (value)' => 'up(1)',
        'Deferred Transmissions' => '0',
        'Inbound Non-Unicast Packets' => '18997',
        'Operation Status (value)' => 'up(1)',
        'Speed' => '1000000000',
        'Type (value)' => 'ethernet-csmacd(6)',
        'Carrier Sense Errors' => '0',
        'Inbound Discards' => '0',
        'Outbound Non-Unicast Packets' => '11245',
        'MTU Size' => '1500',
        'Inbound Unknown Protocols' => '235',
        'Index' => '1',
        'Excessive Collisions' => '0',
        'Multiple Collision Frames' => '0',
        'Inbound Errors' => '0',
        'Internal MAC Transmit Errors' => '0',
        'Outbound Unicast Packets' => '507550720',
        'Inbound Octets' => '3964472983',
        'Station Address' => '0x16353eac5c',
        'Description' => 'lan0 HP PCI-X 1000Base-T Release PHNE_36236 B.11.23.0706.02',
        'Frames Too Long' => '0'
    },
    'hpux1-1' => {
        'Outbound Discards' => '0',
        'PPA Number' => '1',
        'Outbound Octets' => '0',
        'Internal MAC Receive Errors' => '0',
        'Inbound Unicast Packets' => '0',
        'Specific' => '655367',
        'Late Collisions' => '0',
        'Outbound Queue Length' => '0',
        'Outbound Errors' => '0',
        'Alignment Errors' => '0',
        'Single Collision Frames' => '0',
        'FCS Errors' => '0',
        'Last Change' => '284',
        'Administration Status (value)' => 'up(1)',
        'Deferred Transmissions' => '0',
        'Inbound Non-Unicast Packets' => '30242',
        'Operation Status (value)' => 'up(1)',
        'Speed' => '1000000000',
        'Type (value)' => 'ethernet-csmacd(6)',
        'Carrier Sense Errors' => '0',
        'Inbound Discards' => '0',
        'Outbound Non-Unicast Packets' => '0',
        'MTU Size' => '1500',
        'Inbound Unknown Protocols' => '30242',
        'Index' => '2',
        'Excessive Collisions' => '0',
        'Multiple Collision Frames' => '0',
        'Inbound Errors' => '0',
        'Internal MAC Transmit Errors' => '0',
        'Outbound Unicast Packets' => '0',
        'Inbound Octets' => '2951500',
        'Station Address' => '0x16353eac5d',
        'Description' => 'lan1 HP PCI-X 1000Base-T Release PHNE_36236 B.11.23.0706.02',
        'Frames Too Long' => '0'
    },
    'hpux2-0' => {
        'Outbound Discards' => '0',
        'PPA Number' => '0',
        'Outbound Octets' => '3382475092',
        'Internal MAC Receive Errors' => '0',
        'Inbound Unicast Packets' => '1565864523',
        'Specific' => '655367',
        'Late Collisions' => '0',
        'Outbound Queue Length' => '0',
        'Outbound Errors' => '0',
        'Alignment Errors' => '0',
        'Single Collision Frames' => '0',
        'FCS Errors' => '0',
        'Last Change' => '268',
        'Administration Status (value)' => 'up(1)',
        'Deferred Transmissions' => '0',
        'Inbound Non-Unicast Packets' => '1',
        'Operation Status (value)' => 'up(1)',
        'Speed' => '1000000000',
        'Type (value)' => 'ethernet-csmacd(6)',
        'Carrier Sense Errors' => '0',
        'Inbound Discards' => '0',
        'Outbound Non-Unicast Packets' => '40950',
        'MTU Size' => '1500',
        'Inbound Unknown Protocols' => '55',
        'Index' => '1',
        'Excessive Collisions' => '0',
        'Multiple Collision Frames' => '0',
        'Inbound Errors' => '0',
        'Internal MAC Transmit Errors' => '0',
        'Outbound Unicast Packets' => '630798380',
        'Inbound Octets' => '1555284142',
        'Station Address' => '0x18fe28e080',
        'Description' => 'lan0 HP PCI-X 1000Base-T Release PHNE_36236 B.11.23.0706.02',
        'Frames Too Long' => '0'
    },
    'hpux2-1' => {
        'Outbound Discards' => '0',
        'PPA Number' => '1',
        'Outbound Octets' => '0',
        'Internal MAC Receive Errors' => '0',
        'Inbound Unicast Packets' => '0',
        'Specific' => '655367',
        'Late Collisions' => '0',
        'Outbound Queue Length' => '0',
        'Outbound Errors' => '0',
        'Alignment Errors' => '0',
        'Single Collision Frames' => '0',
        'FCS Errors' => '0',
        'Last Change' => '283',
        'Administration Status (value)' => 'up(1)',
        'Deferred Transmissions' => '0',
        'Inbound Non-Unicast Packets' => '40951',
        'Operation Status (value)' => 'up(1)',
        'Speed' => '1000000000',
        'Type (value)' => 'ethernet-csmacd(6)',
        'Carrier Sense Errors' => '0',
        'Inbound Discards' => '0',
        'Outbound Non-Unicast Packets' => '0',
        'MTU Size' => '1500',
        'Inbound Unknown Protocols' => '40951',
        'Index' => '2',
        'Excessive Collisions' => '0',
        'Multiple Collision Frames' => '0',
        'Inbound Errors' => '0',
        'Internal MAC Transmit Errors' => '0',
        'Outbound Unicast Packets' => '0',
        'Inbound Octets' => '2620864',
        'Station Address' => '0x18fe28e081',
        'Description' => 'lan1 HP PCI-X 1000Base-T Release PHNE_36236 B.11.23.0706.02',
        'Frames Too Long' => '0'
    },
);

my %ifconfig_tests = (
     'hpux1-lan0' => {
          status  => 'Up',
          netmask => '255.255.255.224',
          address => '10.0.4.56'
     },
     'hpux2-lan0' => {
          status  => 'Up',
          netmask => '255.255.255.224',
          address => '10.0.0.48'
     },
);

plan tests =>
    (scalar keys %lanadmin_tests) +
    (scalar keys %ifconfig_tests);

foreach my $test (keys %lanadmin_tests) {
    my $file = "resources/hpux/lanadmin/$test";
    my $info = FusionInventory::Agent::Task::Inventory::Input::HPUX::Networks::_getLanadminInfo(file => $file);
    is_deeply($info, $lanadmin_tests{$test}, "lanadmin parsing: $test");
}

foreach my $test (keys %ifconfig_tests) {
    my $file = "resources/generic/ifconfig/$test";
    my $info = FusionInventory::Agent::Task::Inventory::Input::HPUX::Networks::_getIfconfigInfo(file => $file);
    is_deeply($info, $ifconfig_tests{$test}, "ifconfig parsing: $test");
}
