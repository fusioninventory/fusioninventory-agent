package FusionInventory::Agent::Task::Inventory::OS::Win32::Slots;

use strict;
use warnings;

# Had never been tested. There is no slot on my virtal machine.
use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }


    my @slots;
    foreach my $Properties
        (getWmiProperties('Win32_SystemSlot',
qw/Name Description SlotDesignation Status Shared/)) {

        push @slots, {

            NAME => $Properties->{Name},
            DESCRIPTION => $Properties->{Description},
            DESIGNATION => $Properties->{SlotDesignation},
            STATUS => $Properties->{Status},
            SHARED => $Properties->{Shared}

        };

    }

    foreach (@slots) {
        $inventory->addSlot($_);
    }

}
1;
