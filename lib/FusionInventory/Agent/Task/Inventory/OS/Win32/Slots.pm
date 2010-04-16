package FusionInventory::Agent::Task::Inventory::OS::Win32::Slots;
# Had never been tested. There is no slot on my virtal machine.
use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}

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
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_SystemSlot' ) ) )
    {


        push @slots, {

            NAME => $Properties->{Name},
            DESCRIPTION => $Properties->{Description},
            DESIGNATION => $Properties->{SlotDesignation},
            STATUS => $Properties->{Status},
            SHARED => $Properties->{Shared}

        };

    }

    foreach (@slots) {
        $inventory->addSlots($_);
    }

}
1;
