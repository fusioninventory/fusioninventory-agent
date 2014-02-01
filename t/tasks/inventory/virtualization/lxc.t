#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Virtualization::Lxc;

my %result_lxc_info = (
    'lxc-info_-n_name1' => {
        STATUS => 'running',
        VMID   => '13018'
    },
    'lxc-info_-n_name2' => {
        STATUS => 'running',
        VMID   => '5790'
    }
);

my $result_config = {
    MEMORY => '2048000',
    MAC    => '01:23:45:67:89:0A',
    VCPU   => 4
};

plan tests => 4;

for my $file (keys %result_lxc_info) {
    my $state = FusionInventory::Agent::Task::Inventory::Virtualization::Lxc::_getVirtualMachineState(
        file => "resources/virtualization/lxc/$file"
    );
    cmp_deeply($state, $result_lxc_info{$file}, "lxc-info -n name1 -1");
}

my $config = FusionInventory::Agent::Task::Inventory::Virtualization::Lxc::_getVirtualMachineConfig(
    file => 'resources/virtualization/lxc/config'
);
cmp_deeply($config, $result_config, "parsing lxc config sample");
