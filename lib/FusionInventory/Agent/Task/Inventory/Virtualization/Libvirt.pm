package FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::Simple;

sub isInventoryEnabled {
    return can_run('virsh');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $command = 'virsh list --all 2>/dev/null';
    my $handle;
    if (!open $handle, '-|', $command) {
         warn "Can't run $command: $ERRNO";
         return;
    }

    while (my $line = <$handle>) {
        next if $line =~ /^\s*Id/;
        next if $line =~ /^-{5}/;

        if ($line =~ /^\s*(\d+|\-)\s+(\S+)\s+(\S.+)/) {
            my $vmid = $1;
            # hack to avoid a warning if $1 is not a int
            # better fix in 2.2.x branch
            $vmid = 0 unless $vmid =~ /^\d+$/;
            my $name = $2;
            my $status = $3;

            # Xen DomU
            next if $name eq 'Domain-0';

            $status =~ s/^shut off/off/;

            my $xml = `virsh dumpxml $name`;
            my $data = eval { XMLin($xml) };

            my $vcpu = $data->{vcpu};
            my $uuid = $data->{uuid};
            my $vmtype = $data->{type};
            my $memory;
            if ($data->{currentMemory} =~ /(\d+)\d{3}$/) {
                $memory = $1;
            }

            my $machine = {
                MEMORY => $memory,
                NAME => $name,
                UUID => $uuid,
                STATUS => $status,
                SUBSYSTEM => $vmtype,
                VMTYPE => "libvirt",
                VMID => $vmid,
                VCPU   => $vcpu,
            };

            $inventory->addVirtualMachine($machine);
        }
    }
    close $handle;

}

1;
