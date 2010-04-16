package FusionInventory::Agent::Task::Inventory::OS::Win32::Drives;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);


my @type = (
        'Unknown', 
        'No Root Directory',
        'Removable Disk',
        'Local Disk',
        'Network Drive',
        'Compact Disc',
        'RAM Disk'
        ); 

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


    my @drives;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_LogicalDisk' ) ) )
    {

        push @drives, {

            CREATEDATE => $Properties->{InstallDate},
                       DESCRIPTION => encode('UTF-8',$Properties->{Description}),
                       FREE => int($Properties->{FreeSpace}/(1024*1024)),
                       FILESYSTEM => $Properties->{FileSystem},
                       LABEL => encode('UTF-8', $Properties->{VolumeName}),
                       LETTER => $Properties->{DeviceID} || $Properties->{Caption},
                       SERIAL => $Properties->{VolumeSerialNumber},
                       TOTAL => int($Properties->{Size}/(1024*1024)),
                       TYPE => $type[$Properties->{DriveType}] || 'Unknown',
                       VOLUMN => encode('UTF-8', $Properties->{VolumeName}),

        };

    }
    foreach (@drives) {
        $inventory->addDrives($_);
    }

}
1;
