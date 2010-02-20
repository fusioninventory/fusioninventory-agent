package FusionInventory::Agent::Task::Inventory::OS::Win32::Bios;

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
                    'Win32_Bios' ) ) )
    {

        my $smodel = $Properties->{SerialNumber};
        my $smanufacturer;
        my $ssn;
        my $bdate;
        my $bversion = $Properties->{Version};
        my $bmanufacturer = $Properties->{Manufacturer};
        my $mmanufacturer;
        my $msn;
        my $model;
        my $assettag;



        $inventory->setBios({
                SMODEL => $smodel,
                SMANUFACTURER =>  $smanufacturer,
                SSN => $ssn,
                BDATE => $bdate,
                BVERSION => $bversion,
                BMANUFACTURER => $bmanufacturer,
                MMANUFACTURER => $mmanufacturer,
                MSN => $msn,
                MMODEL => $model,
                ASSETTAG => $assettag

                });

    }


    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_SystemEnclosure' ) ) )
    {

        my $assettag = $Properties->{Manufacturer};

        $inventory->setBios({
                
                ASSETTAG => $assettag

                });

    }

}
1;
