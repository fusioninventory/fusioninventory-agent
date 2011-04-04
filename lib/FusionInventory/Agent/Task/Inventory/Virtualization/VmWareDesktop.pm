package FusionInventory::Agent::Task::Inventory::Virtualization::VmWareDesktop;
#
# initial version: Walid Nouh
#

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return -x '/Library/Application Support/VMware Fusion/vmrun';
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    foreach my $machine (_getMachines(
        command => '/Library/Application Support/VMware Fusion/vmrun', logger => $logger
    )) {
        $inventory->addVirtualMachine($machine);
    }
}

sub _getMachines {
   my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    # skip first line
    my $line = <$handle>;

    my @machines;
    while (my $line = <$handle>) {
        chomp $line;
        next unless -f $line;

        my %info = _getMachineInfo(file => $line, logger => $params{logger});

        my $machine = {
            NAME      => $info{'displayName'},
            VCPU      => 1,
            UUID      => $info{'uuid.bios'},
            MEMORY    => $info{'memsize'},
            STATUS    => "running",
            SUBSYSTEM => "VmWare Fusion",
            VMTYPE    => "VmWare",
        };

        push @machines, $machine;
    }
    close $handle;

    return @machines;
}

sub _getMachineInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my %info;
    while (my $line = <$handle>) {
        next unless $line = /^(\S+)\s*=\s*(\S+.*)/;
        my $key = $1;
        my $value = $2;
        $value =~ s/(^"|"$)//g;
        $info{$key} = $value;
    }
    close $handle;

    return %info;
}

1;
