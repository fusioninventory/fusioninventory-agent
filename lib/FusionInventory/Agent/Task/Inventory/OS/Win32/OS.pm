package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;


sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};



    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_OperatingSystem' ) ) )
    {

        my $osname = $Properties->{Caption};
        my $osversion = $Properties->{Version};
        my $serialnumber = $Properties->{SerialNumber};




        $inventory->setHardware({

                OSNAME =>  $osname,
                OSVERSION =>  $osversion,
                WINPRODKEY => $serialnumber,

                });



    }
}
1;
