#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

my %tests = (
    sample1 => [
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Fusion-UsineRefav',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '855MB',
            UUID      => '03a37b40-31f0-4c10-8a92-472d02b02221',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Leopard2',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '1024MB',
            UUID      => 'd2ba1d3d-f682-4e25-b5a7-47eea52253bc',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Snow64',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '509c9563-05c7-4654-b8a4-ce7d639148bc',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Win2k',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '256MB',
            UUID      => 'dba8762a-ed1e-4984-ba06-dad9ed981a5a',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSuse',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '6047a446-06fd-45ad-8829-cb2b7d81c8a2',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSolaris',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '768MB',
            UUID      => '201ca94e-66fb-4d3f-b2af-6d1b4746e77b',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandriva',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '46f9d625-923a-41fb-8518-53c58a041142',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'openbsd47',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '671MB',
            UUID      => '347850fa-1279-4678-89eb-19f53f1f021c',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'netbsd',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => '4ddac902-a4f6-4ccb-a1a4-73dd6c90c1b2',
            VCPU      => 1
        }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/vboxmanage/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox::_parseVBoxManage(file => $file);
    is_deeply(\@machines, $tests{$test}, $test);
}
