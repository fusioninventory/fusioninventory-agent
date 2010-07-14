package FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('virsh');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    chomp (my $subsystem = `libvirtd --version`);
    my $command = 'virsh list --all 2>/dev/null';
    my $handle;
    if (!open $handle, '-|', $command) {
         warn "Can't run $command: $ERRNO";
         return;
    }

    while (my $line = <$handle>) {
        if ($line =~ /^\s+(\d+|\-)\s+(\S+)\s+(\S.+)/) {
            my $name = $2;
            my $status = $3;
            $status =~ s/^shut off/off/;

            my $xml = `virsh dumpxml $name`;

            my $tpp = XML::TreePP->new();
            my $data = $tpp->parse( $xml );

            my $vcpu = $data->{domain}->{vcpu};
            my $uuid = $data->{domain}->{uuid};
            my $vmtype = $data->{domain}->{type};
            my $memory = $1 if $data->{domain}->{currentMemory} =~ /(\d+)\d{3}$/;

            my $machine = {
                MEMORY => $memory,
                NAME => $name,
                UUID => $uuid,
                STATUS => $status,
                SUBSYSTEM => $subsystem,
                VMTYPE => "libvirt",
                VCPU   => $vcpu,
            };

            $inventory->addVirtualMachine($machine);
        }
    }
    close $handle;

}

1;
