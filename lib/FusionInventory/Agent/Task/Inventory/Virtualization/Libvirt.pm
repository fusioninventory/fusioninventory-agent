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
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'virsh list --all',
        logger => $logger
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /^\s+(\d+|\-)\s+(\S+)\s+(\S.+)/;

        my $name = $2;
        my $status = $3;
        $status =~ s/^shut off/off/;
        my $xml = `virsh dumpxml $name`;

        my $tpp = XML::TreePP->new();
        my $data = $tpp->parse( $xml );

        my $vcpu = $data->{domain}->{vcpu};
        my $uuid = $data->{domain}->{uuid};
        my $vmtype = $data->{domain}->{type};
        my $memory;
        if ($data->{currentMemory} =~ /(\d+)\d{3}$/) {
            $memory = $1;
        }

        my $machine = {
            MEMORY    => $memory,
            NAME      => $name,
            UUID      => $uuid,
            STATUS    => $status,
            SUBSYSTEM => $vmtype,
            VMTYPE    => "libvirt",
            VCPU      => $vcpu,
        };

        $inventory->addVirtualMachine($machine);
    }
    close $handle;

}

1;
