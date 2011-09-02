#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Virtualization::Xen;

my %tests = (
    sample1 => [
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

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/xm/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Input::Virtualization::Xen::_getVirtualMachines(file => $file);
    is_deeply(\@machines, $tests{$test}, $test);
}

