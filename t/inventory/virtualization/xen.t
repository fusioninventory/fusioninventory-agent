#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Virtualization::Xen;

my %tests_xm_list = (
    xm_list => [
        {
            NAME      => 'Fedora3',
            SUBSYSTEM => 'xm',
            STATUS    => 'running',
            VMID      => '164',
            VMTYPE    => 'xen',
            MEMORY    => '128',
            VCPU      => '1'
        },
        {
            NAME      => 'Fedora4',
            SUBSYSTEM => 'xm',
            STATUS    => 'off',
            VMID      => '165',
            VMTYPE    => 'xen',
            MEMORY    => '128',
            VCPU      => '1'
        },
        {
            NAME      => 'Mandrake2006',
            SUBSYSTEM => 'xm',
            STATUS    => 'blocked',
            VMID      => '166',
            VMTYPE    => 'xen',
            MEMORY    => '128',
            VCPU      => '1'
        },
        {
            NAME      => 'Mandrake10.2',
            SUBSYSTEM => 'xm',
            STATUS    => 'off',
            VMID      => '167',
            VMTYPE    => 'xen',
            MEMORY    => '128',
            VCPU      => '1'
        },
        {
            NAME      => 'Suse9.2',
            SUBSYSTEM => 'xm',
            STATUS    => 'off',
            VMID      => '168',
            VMTYPE    => 'xen',
            MEMORY    => '100',
            VCPU      => '1'
        }
    ]
);


my %tests_getUUID = (
    'xm_list_-l_vmname' => '0004fb00-0006-0000-4acc-3678187fb85c'
);

plan tests => scalar keys (%tests_xm_list) + scalar keys (%tests_getUUID);

foreach my $test (keys %tests_xm_list) {
    my $file = "resources/virtualization/xm/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Xen::_getVirtualMachines(file => $file);
    cmp_deeply(\@machines, $tests_xm_list{$test}, $test);
}

foreach my $test (keys %tests_getUUID) {
    my $file = "resources/virtualization/xm/$test";
    my $uuid = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Xen::_getUUID(file => $file);
    cmp_deeply($uuid, $tests_getUUID{$test}, $test);
}

