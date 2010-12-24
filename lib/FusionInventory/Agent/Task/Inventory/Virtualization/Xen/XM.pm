package FusionInventory::Agent::Task::Inventory::Virtualization::Xen::XM;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('xm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{inventory};

    # xm status
    my %status_list = (
        'r' => 'running',
        'b' => 'blocked',
        'p' => 'paused',
        's' => 'shutdown',
        'c' => 'crashed',
        'd' => 'dying',
    );

    my $handle = getFileHandle(
        command => 'xm list',
        logger => $logger,
    );

    return unless $handle;

    # drop headers
    my $line  = <$handle>;

    while (my $line = <$handle>) {
        chomp $line;
        my ($name, $vmid, $memory, $vcpu, $status, $time) = split(' ', $line);

        $status =~ s/-//g;
        $status = $status ? $status_list{$status} : 'off';

        my @vm_info = `xm list -l $name`;
        my $uuid;
        foreach my $value (@vm_info) {
            chomp $value;
            if ($value =~ /uuid/) {
                $value =~ s/\(|\)//g;
                $value =~ s/\s+.*uuid\s+(.*)/$1/;
                $uuid = $value;
                last;
            }
        }

        my $machine = {
            MEMORY    => $memory,
            NAME      => $name,
            UUID      => $uuid,
            STATUS    => $status,
            SUBSYSTEM => 'xm',
            VMTYPE    => 'xen',
            VCPU      => $vcpu,
            VMID      => $vmid,
        };

        $inventory->addVirtualMachine($machine);
    }
    close $handle;
}

1;
