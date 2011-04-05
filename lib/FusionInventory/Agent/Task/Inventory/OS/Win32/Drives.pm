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
    foreach my $object (getWmiObjects(
        class      => 'Win32_OperatingSystem',
        properties => [ qw/SystemDrive/ ]
    )) {
        $systemDrive = lc($object->{SystemDrive});
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_LogicalDisk',
        properties => [ qw/
            InstallDate Description FreeSpace FileSystem VolumeName Caption
            VolumeSerialNumber DeviceID Size DriveType VolumeName
        / ]
    )) {

        my $freespace;
        my $size;

        if ($object->{FreeSpace}) {
            $freespace = int($object->{FreeSpace}/(1024*1024))
        }
        if ($object->{Size}) {
            $size = int($object->{Size}/(1024*1024))
        }

        $inventory->addDrive({
            CREATEDATE  => $object->{InstallDate},
            DESCRIPTION => $object->{Description},
            FREE        => $freespace,
            FILESYSTEM  => $object->{FileSystem},
            LABEL       => $object->{VolumeName},
            LETTER      => $object->{DeviceID} || $object->{Caption},
            SERIAL      => $object->{VolumeSerialNumber},
            SYSTEMDRIVE => (lc($object->{DeviceID}) eq $systemDrive),
            TOTAL       => $size,
            TYPE        => $type[$object->{DriveType}] || 'Unknown',
            VOLUMN      => $object->{VolumeName},
        });
    }
}

1;
