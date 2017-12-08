package FusionInventory::Agent::Task::Inventory::Virtualization::Lxd;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('lxd');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @machines = _getVirtualMachines(
        command => '/usr/bin/lxc list',
        logger  => $logger
    );

    foreach my $machine (@machines) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES',
            entry   => $machine
        );
    }
}

sub  _getVirtualMachineState {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my %info;
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ m/^(\S+):\s*(\S+)$/;
        $info{lc($1)} = $2;
    }
    close $handle;

    my $state;
    $state->{VMID} = $info{pid};

    $state->{STATUS} =
        $info{status} eq 'Running' ? 'running' :
        $info{status} eq 'FROZEN'  ? 'paused'  :
        $info{status} eq 'Stopped' ? 'off'     :
        $info{status};

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
        next unless $line =~ m/^\s*(\S+)\s*:\s*(\S+)\s*$/;

        my $key = $1;
        my $val = $2;
        if ($key eq 'volatile.eth0.hwaddr') {
            $config->{MAC} = $val;
        }

        if ($key eq 'limits.memory') {
            $config->{MEMORY} = $val;
        }

        if ($key eq 'lxc.cgroup.cpuset.cpus') {
###eg: lxc.cgroup.cpuset.cpus = 0,3-5,7,2,1
            foreach my $cpu ( split( /,/, $val ) ) {
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

    my @machines;

    while(my $line = <$handle>) {
        chomp $line;

        # Filter header
        next if ($line =~ /NAME.*STATE/);

        my ($name) = $line =~ /^\|+\s*([^| ]+)/;
        next unless $name;

        my $state = _getVirtualMachineState(
            command => "/usr/bin/lxc info $name",
            logger  => $params{logger}
        );

        my $config = _getVirtualMachineConfig(
            command => "lxc config show $name",
            logger  => $params{logger}
        );

        push @machines, {
            NAME   => $name,
            VMTYPE => 'LXD',
            STATUS => $state->{STATUS},
            VCPU   => $config->{VCPU},
            MEMORY => $config->{MEMORY},
        };
    }
    close $handle;

    return @machines;
}

1;
