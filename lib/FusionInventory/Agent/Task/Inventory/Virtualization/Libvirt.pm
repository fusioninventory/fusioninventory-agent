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

sub _getMachineInfos {
    my %params = @_;
    my $xml = getAllLines(%params);

    if (!$xml) {
        $params{logger}->error("No virsh xmldump output");
        return;
    }

    my $tpp = XML::TreePP->new();

    my $vcpu;
    my $uuid;
    my $vmtype;
    my $memory;

    eval {
        my $data = $tpp->parse($xml);

        $vcpu = $data->{domain}->{vcpu};
        $uuid = $data->{domain}->{uuid};
        $vmtype = $data->{domain}->{'-type'};
        if ($data->{domain}{currentMemory} =~ /(\d+)\d{3}$/) {
            $memory = $1;
        }
    };
    if ($@) {
        $params{logger}->error("Failed to parse XML output");
    }


    return (
        vcpu => $vcpu,
        uuid => $uuid,
        vmtype => $vmtype,
        memory => $memory,
    );
}

sub _getMachines {
    my %params = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @machines;
    while (my $line = <$handle>) {
        next if $line =~ /^\s*Id/;
        next if $line =~ /^-{5}/;
        next unless $line =~ /^\s*(\d+|)(\-|)\s+(\S+)\s+(\S.+)/;

        my $vmid = $1;
        my $name = $3;

        # ignore Xen Dom0
        next if $name eq 'Domain-0';

        my $status = $4;
        $status =~ s/^shut off/off/;

        my %infos = _getMachineInfos(command => "virsh dumpxml $name", logger => $params{logger});

        my $machine = {
            MEMORY    => $infos{memory},
            NAME      => $name,
            UUID      => $infos{uuid},
            STATUS    => $status,
            SUBSYSTEM => $infos{vmtype},
            VMTYPE    => "libvirt",
            VMID      => $vmid,
            VCPU      => $infos{vcpu},
        };

        push @machines, $machine;
    }
    close $handle;

    return @machines;
}

1;
