package FusionInventory::Agent::Task::Inventory::OS::Win32::Video;

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
                    'Win32_VideoController' ) ) )
    {

        my $resolution;
        if ($Properties->{CurrentHorizontalResolution}) {
            $resolution = $Properties->{CurrentHorizontalResolution} ." x
                ".$Properties->{CurrentVerticalResolution};
        }

        $inventory->addVideo({
                CHIPSET => $Properties->{VideoProcessor},
                MEMORY =>  int($Properties->{AdaptaterRAM} / (1024*1024)),
                NAME => $Properties->{Name},
                RESOLUTION => $resolution
                });

    }




}
1
