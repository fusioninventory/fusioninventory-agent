package FusionInventory::Agent::Task::Inventory::Virtualization::Lxc;

# Authors: Egor Shornikov <se@wbr.su>, Egor Morozov <akrus@flygroup.st>
# License: GPLv2+

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('lxc-ls');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    my $vms = _getVirtualMachines(
        command => '/usr/bin/lxc-ls -1',
        logger => $logger
    );
    foreach my $vm ( keys %{$vms}) {

        my $state = _getVirtualMachineState(
            command => "/usr/bin/lxc-info -n $vm",
            logger => $logger
        );

        my $config = _getVirtualMachineConfig(
            file => "/var/lib/lxc/$vm/config",
            logger => $logger
        );

        my $machine = {
            NAME   => $vm,
            VMTYPE => 'LXC',
            VMID   => $state->{VMID},
            STATUS => $state->{STATUS},
            VCPU   => $config->{VCPU},
            MEMORY => $config->{MEMORY},
        };

        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub  _getVirtualMachineState {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my %info;
    while (my $line = <$handle>){
        chomp $line;
        next unless $line =~ m/^(\S+):\s*(\S+)$/;
        $info{$1} = $2;
    }
    close $handle;

    my $state;
    $state->{VMID} = $info{pid};
    $state->{STATUS} =
        $info{state} eq 'RUNNING' ? 'running' :
        $info{state} eq 'FROZEN'  ? 'paused'  :
        $info{state} eq 'STOPPED' ? 'off'     :
        $info{state};

    return $state;
}

sub  _getVirtualMachineConfig {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $config = {
        VCPU => 0
    };

    while (my $line = <$handle>) {
        chomp $line;
        next if $line =~ /^#.*/;
        next unless $line =~ m/^\s*(\S+)\s*=\s*(\S+)\s*$/;

        my $key = $1;
        my $val = $2;
        if ($key eq 'lxc.network.hwaddr') {
            $config->{MAC} = $val;
        }

        if ($key eq 'lxc.cgroup.memory.limit_in_bytes') {
            $config->{MEMORY} = $val;
        }

        if ($key eq 'lxc.cgroup.cpuset.cpus') {
            ###eg: lxc.cgroup.cpuset.cpus = 0,3-5,7,2,1
            foreach my $cpu ( split( /,/, $val ) ){
                if ( $cpu =~ /(\d+)-(\d+)/ ){
                    my @tmp = ($1..$2);
                    $config->{VCPU} += $#tmp + 1;
                } else {
                    $config->{VCPU} += 1;
                }
            }
        }
    }
    close $handle;

    return $config;
}

sub  _getVirtualMachines {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $vms;

    while(my $line = <$handle>) {
        chomp $line;
        next unless $line =~ m/^(\S+)$/;
        $vms->{$1} = 1;
    }
    close $handle;

    return $vms;
}

1;
