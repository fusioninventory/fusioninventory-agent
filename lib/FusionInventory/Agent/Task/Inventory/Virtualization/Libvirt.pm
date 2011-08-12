package FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;

use strict;
use warnings;

use XML::TreePP;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('virsh');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $machine (_getMachines(
        command => 'virsh list --all', logger => $logger
    )) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getMachines {
    my %params = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @machines;
    while (my $line = <$handle>) {
        next unless $line =~ /^\s*(\d+|\-)\s+(\S+)\s+(\S.+)/;

        my $vmid = int($1);
        my $name = $2;

        # ignore Xen Dom0
        next if $name eq 'Domain-0';

        my $status = $3;
        $status =~ s/^shut off/off/;

        my $xml = getAllLines(command => "virsh dumpxml $name", logger => $params{logger});
        my $tpp = XML::TreePP->new();
        my $data = $tpp->parse($xml);

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
            VMID      => $vmid,
            VCPU      => $vcpu,
        };

        push @machines, $machine;
    }
    close $handle;

    return @machines;
}

1;
