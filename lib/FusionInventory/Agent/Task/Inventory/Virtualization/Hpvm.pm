package FusionInventory::Agent::Task::Inventory::Virtualization::Hpvm;

use strict;
use warnings;

use XML::TreePP;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('hpvmstatus');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my %memory_unit_mult = (
        'MB' => 1,
        'GB' => 1024,
    );

    my %status_list = (
        'On' => 'running',
        'Off' => 'off',
        'Invalid' => 'crashed',
    );

    my $xml = getAllLines(command => 'hpvmstatus -X', logger => $logger);
    my $tpp = XML::TreePP->new();
    my $data = $tpp->parse($xml);

    my $mvs = $data->{pman}->{virtual_machine};

    foreach my $name (keys %$mvs) {
        my $memory = $mvs->{$name}->{memory}->{total}->{content};
        $memory *= $memory_unit_mult{$mvs->{$name}->{memory}->{total}->{unit}};

        my $uuid = $mvs->{$name}->{uuid};
        my $status = $status_list{$mvs->{$name}->{vm_state}};
        my $vcpu = $mvs->{$name}->{vcpu_number};
        my $vmid = $mvs->{$name}->{local_id};

        my $machine = {
            MEMORY => $memory,
            NAME => $name,
            UUID => $uuid,
            STATUS => $status,
            SUBSYSTEM => "HPVM",
            VMTYPE => "HPVM",
            VCPU => $vcpu,
            VMID => $vmid,
        };

        $inventory->addVirtualMachine($machine);
    }
}

1;

