package FusionInventory::Agent::Task::Inventory::Virtualization::Hpvm;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;

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
    my $tpp = XML::TreePP->new();
    my $data = $tpp->parse( $xml );

    my $mvs = $data->{hpvm}->{pman}->{virtual_machine};

    foreach my $tmpVM (@$mvs) {

        my $memory = $tmpVM->{memory}->{total}->{'#text'};
        $memory *= $memory_unit_mult{$tmpVM->{memory}->{total}->{-unit}};

        my $uuid = $tmpVM->{-uuid};
        my $status = $status_list{$tmpVM->{vm_state}};
        my $vcpu = $tmpVM->{vcpu_number};
        my $vmid = $tmpVM->{-local_id};

        my $machine = {
            MEMORY => $memory,
            NAME => $tmpVM->{-name},
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

