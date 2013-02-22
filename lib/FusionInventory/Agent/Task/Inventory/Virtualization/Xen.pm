package FusionInventory::Agent::Task::Inventory::Virtualization::Xen;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt"];

sub isEnabled {
    return canRun('xm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    my $command = 'xm list';
    foreach my $machine (_getVirtualMachines(command => $command, logger => $logger)) {
        my $uuid = _getUUID(
            command => "xm list -l $machine->{NAME}",
            logger  => $logger
        );
        $machine->{UUID} = $uuid;
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getUUID {
    my (%params) = @_;

    return getFirstMatch(
        pattern => qr/\( uuid \s ([^)]+) \)/x,
        %params
    );
}

sub  _getVirtualMachines {

    my $handle = getFileHandle(@_);

    return unless $handle;

    # xm status
    my %status_list = (
        'r' => 'running',
        'b' => 'blocked',
        'p' => 'paused',
        's' => 'shutdown',
        'c' => 'crashed',
        'd' => 'dying',
    );

    # drop headers
    my $line  = <$handle>;

    my @machines;
    while (my $line = <$handle>) {
        chomp $line;
        my ($name, $vmid, $memory, $vcpu, $status) = split(' ', $line);
        next if $name eq 'Domain-0';
        next if $vmid == 0;

        $status =~ s/-//g;
        $status = $status ? $status_list{$status} : 'off';

        my $machine = {
            MEMORY    => $memory,
            NAME      => $name,
            STATUS    => $status,
            SUBSYSTEM => 'xm',
            VMTYPE    => 'xen',
            VCPU      => $vcpu,
            VMID      => $vmid,
        };

        push @machines, $machine;

    }
    close $handle;

    return @machines;
}

1;
