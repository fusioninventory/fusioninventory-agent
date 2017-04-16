#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::Generic::Firewall;
use FusionInventory::Agent::Task::Inventory::Generic::Firewall::Ubuntu;
use FusionInventory::Agent::Task::Inventory::Generic::Firewall::Fedora;

use Test::More;

my $expectedUbuntu = {
    'ubuntu_ufw_status_ON.txt'  => FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_ON,
    'ubuntu_ufw_status_OFF.txt' => FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_OFF
};

my $expectedFedora = {
    'fedora_systemctl_status_firewalld.service_ON.txt'  => FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_ON,
    'fedora_systemctl_status_firewalld.service_OFF.txt' => FusionInventory::Agent::Task::Inventory::Generic::Firewall::STATUS_OFF
};

plan tests => scalar (keys %$expectedUbuntu)
        + scalar (keys %$expectedFedora);

for my $testfile (keys %$expectedUbuntu) {
    my $statusGot = FusionInventory::Agent::Task::Inventory::Generic::Firewall::Ubuntu::_getFirewallStatus(
        file => 'resources/linux/firewall/' . $testfile
    );
    ok ($statusGot eq $expectedUbuntu->{$testfile});
}

for my $testfile (keys %$expectedFedora) {
    my $statusGot = FusionInventory::Agent::Task::Inventory::Generic::Firewall::Fedora::_getFirewallStatus(
        file => 'resources/linux/firewall/' . $testfile
    );
    ok ($statusGot eq $expectedFedora->{$testfile});
}
