package FusionInventory::Agent::Task::Inventory::OS::Win32::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

my @type = (
    'Unknown', 
    'No Root Directory',
    'Removable Disk',
    'Local Disk',
    'Network Drive',
    'Compact Disc',
    'RAM Disk'
); 

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $systemDrive;
    foreach my $Properties (getWmiProperties('Win32_OperatingSystem', qw/
        SystemDrive
    /)) {
        $systemDrive = lc($Properties->{SystemDrive});
    }

    foreach my $Properties (getWmiProperties('Win32_LogicalDisk', qw/
        InstallDate Description FreeSpace FileSystem VolumeName Caption
        VolumeSerialNumber DeviceID Size DriveType VolumeName
    /)) {

        my $freespace;
        my $size;

        if ($Properties->{FreeSpace}) {
            $freespace = int($Properties->{FreeSpace}/(1024*1024))
        }
        if ($Properties->{Size}) {
            $size = int($Properties->{Size}/(1024*1024))
        }

        $inventory->addDrive({
            CREATEDATE => $Properties->{InstallDate},
            DESCRIPTION => $Properties->{Description},
            FREE => $freespace,
            FILESYSTEM => $Properties->{FileSystem},
            LABEL => $Properties->{VolumeName},
            LETTER => $Properties->{DeviceID} || $Properties->{Caption},
            SERIAL => $Properties->{VolumeSerialNumber},
            SYSTEMDRIVE => (lc($Properties->{DeviceID}) eq $systemDrive),
            TOTAL => $size,
            TYPE => $type[$Properties->{DriveType}] || 'Unknown',
            VOLUMN => $Properties->{VolumeName},
        });
    }
}

1;
