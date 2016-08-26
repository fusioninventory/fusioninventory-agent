package FusionInventory::Agent::Task::Inventory::Virtualization::XenCitrixServer;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt"];

sub isEnabled {
    return canRun('xe');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = 'xe vm-list';
    foreach my $machine (_getUUID(command => $command, logger => $logger)) {
        my $machineextend = _getVirtualMachines(
            command => "xe vm-param-list uuid=$machine->{UUID}",
            logger  => $logger,
        );
        foreach my $key ($machineextend) {
            $machine->{$key} = $machineextend->{$key};
        }

        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getUUID {

    my $handle = getFileHandle(@_);

    return unless $handle;

    my @machines;
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /uuid \( RO\)/;
        my (undef, $uuid) = split(':', $line);
        chomp $uuid;

        my $machine = {
            UUID      => $uuid,
            SUBSYSTEM => 'xe',
            VMTYPE    => 'xen',
        };

        push @machines, $machine;

    }
    close $handle;

    return @machines;
}

sub  _getVirtualMachines {

    my $handle   = getFileHandle(@_);

    return unless $handle;

    # xe status
    my %status_list = (
        'running' => 'running',
        'halted'  => 'shutdown',
    );

    my $machine;

    while (my $line = <$handle>) {
        chomp $line;
        my ($extendedlabel, $value) = split('\): ', $line);
        chomp $value;
        if ($extendedlabel =~ /name-label/) {
            $machine->{NAME} = $value;
            next;
        }
        if ($extendedlabel =~ /memory-actual/) {
            $machine->{MEMORY} = ($value / 1048576);
            next;
        }
        if ($extendedlabel =~ /power-state/) {
            $machine->{STATUS} = $value ? $status_list{$value} : 'off';
            next;
        }
        if ($extendedlabel =~ /VCPUs-number/) {
            $machine->{VCPU} = $value;
            next;
        }
        if ($extendedlabel =~ /name-description/) {
            next if $value eq '';
            $machine->{COMMENT} = $value;
            next;
        }
    }

    return $machine;
}

1;
