package FusionInventory::Agent::Task::Inventory::OS::Win32::CPU;


use strict;
use Win32::OLE;
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

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf( 'Win32_Processor' ) ) )
    {

        my $cache = $Properties->{L2CacheSize}+$Properties->{L3CacheSize};
        my $core = $Properties->{NumberOfCores};
        my $description = $Properties->{Description};
        my $name = $Properties->{Name};
        my $manufacturer = $Properties->{Manufacturer};
        my $serial = $Properties->{ProcessorId};
        my $speed = $Properties->{MaxClockSpeed};




        $inventory->addCPU({
                CACHE => $cache,
                CORE => $core,
                DESCRIPTION => $description,
                NAME => $name,
                MANUFACTURER => $manufacturer,
                SERIAL => $serial,
                SPEED => $speed

                });
    }



}
1;
