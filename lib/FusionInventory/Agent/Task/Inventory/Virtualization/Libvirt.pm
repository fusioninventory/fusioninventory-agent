package FusionInventory::Agent::Task::Inventory::Virtualization::Libvirt;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('virsh');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $machine (_getMachines(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub _getMachines {
    my (%params) = @_;

    my @machines = _parseList(
        command => 'virsh list --all',
        logger  => $params{logger}
    );

    foreach my $machine (@machines) {
        my %infos = _parseDumpxml(
            command => "virsh dumpxml $machine->{NAME}",
            logger  => $params{logger}
        );

        $machine->{MEMORY}    = $infos{memory};
        $machine->{UUID}      = $infos{uuid};
        $machine->{SUBSYSTEM} = $infos{vmtype};
        $machine->{VCPU}      = $infos{vcpu};
    }

    return @machines;
}

sub _parseList {
    my (%params) = @_;

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

        my $machine = {
            NAME      => $name,
            STATUS    => $status,
            VMTYPE    => "libvirt",
            VMID      => $vmid,
        };

        push @machines, $machine;
    }
    close $handle;

    return @machines;
}

sub _parseDumpxml {
    my (%params) = @_;

    my $xml = getAllLines(%params);
    if (!$xml) {
        $params{logger}->error("No virsh xmldump output");
        return;
    }

    my $data;
    eval {
        $data = XML::TreePP->new()->parse($xml);
    };
    if ($EVAL_ERROR) {
        $params{logger}->error("Failed to parse XML output");
        return;
    }

    my $vcpu   = $data->{domain}->{vcpu};
    my $uuid   = $data->{domain}->{uuid};
    my $vmtype = $data->{domain}->{'-type'};
    my $memory;
    if ($data->{domain}{currentMemory} =~ /(\d+)\d{3}$/) {
        $memory = $1;
    }

    return (
        vcpu => $vcpu,
        uuid => $uuid,
        vmtype => $vmtype,
        memory => $memory,
    );
}

1;
