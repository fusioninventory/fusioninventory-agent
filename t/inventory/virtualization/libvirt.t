#!/usr/bin/perl

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;
use FusionInventory::Agent::Logger;

use Test::More;

my %tests_list = (
    sample1 => [
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm1',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '151',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm2',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '152',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm-ad',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '170',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm-ts',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '178',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm3',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '185',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm4',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '190',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm5',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '208',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm6-ws1',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '209',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vml3',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '210',
            'UUID' => undef,
            'VCPU' => undef
          },
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'vm-srv-net1',
            'SUBSYSTEM' => undef,
            'STATUS' => 'off',
            'MEMORY' => undef,
            'VMID' => '',
            'UUID' => undef,
            'VCPU' => undef
          }
    ],
    sample2 => [
          {
            'VMTYPE' => 'libvirt',
            'NAME' => 'Debian_Squeeze_64_bits',
            'SUBSYSTEM' => undef,
            'STATUS' => 'running',
            'MEMORY' => undef,
            'VMID' => '6',
            'UUID' => undef,
            'VCPU' => undef
          }
    ],
);

my %tests_infos = (
    sample1 => {
          'memory' => '524',
          'vmtype' => 'kvm',
          'uuid' => 'd0f1baf3-ac9d-e828-619f-91f074c8c6c4',
          'vcpu' => '1'
    },
    sample2 => {
          'memory' => '4194',
          'vmtype' => 'kvm',
          'uuid' => '5e3884eb-0caa-194b-cd17-3d9ca1b20c3b',
          'vcpu' => '4'
    },
    sample3 => {
          'memory' => '2097',
          'vmtype' => 'kvm',
          'uuid' => 'aee61d6a-0c2f-f8b6-5246-7c555d803a7d',
          'vcpu' => '2'
    },
);


plan tests => scalar (keys %tests_list) + scalar (keys %tests_infos);

my $logger = FusionInventory::Agent::Logger->new(
    backends => [],
);


foreach my $test (keys %tests_list) {
    my $file = "resources/virtualization/libvirt/virsh_list_--all/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt::_getMachines(file => $file, logger => $logger);
    is_deeply(\@machines, $tests_list{$test}, "parse 'virsh list --all' ".$test);
}

foreach my $test (keys %tests_infos) {
    my $file = "resources/virtualization/libvirt/virsh_dumpxml/$test";
    my %infos = FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt::_getMachineInfos(file => $file, logger => $logger);
    is_deeply(\%infos, $tests_infos{$test}, "parse 'virsh dumpxml' ".$test);
}
