package FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;

use strict;

use XML::Simple;

sub isInventoryEnabled { can_run('virsh') }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    foreach (`virsh list --all 2>/dev/null`) {
        if (/^\s+(\d+|\-)\s+(\S+)\s+(\S.+)/) {
            my $name = $2;
            my $status = $3;

            my $status =~ s/^shut off/off/;
            my $xml = `virsh dumpxml $name`;
            my $data = XMLin($xml);

            my $vcpu = $data->{vcpu};
            my $uuid = $data->{uuid};
            my $vmtype = $data->{type};
            my $memory = $1 if $data->{currentMemory} =~ /(\d+)\d{3}$/;

            my $machine = {

                MEMORY => $memory,
                NAME => $name,
                UUID => $uuid,
                STATUS => $status,
                SUBSYSTEM => "libvirt",
                VMTYPE => $vmtype,
                VCPU   => $vcpu,

            };

            $inventory->addVirtualMachine($machine);

        }
    }

}

1;
