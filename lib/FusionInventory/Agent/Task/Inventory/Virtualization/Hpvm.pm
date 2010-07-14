package FusionInventory::Agent::Task::Inventory::Virtualization::Hpvm;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::Simple;

sub isInventoryEnabled {
    return can_run('hpvmstatus');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %memory_unit_mult = (
        'MB' => 1,
        'GB' => 1024,
    );

    my %status_list = (
        'On' => 'running',
        'Off' => 'off',
        'Invalid' => 'crashed',
    );

    my $xml = `hpvmstatus -X`;
    my $data = XMLin($xml);

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

