package FusionInventory::Agent::Task::Inventory::OS::Win32::CPU;

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
                DESCRIPTION => $description->utf8,
                NAME => $name->utf8,
                MANUFACTURER => $manufacturer->utf8,
                SERIAL => $serial,
                SPEED => $speed

                });
    }



}
1;
