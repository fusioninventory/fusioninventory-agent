package FusionInventory::Agent::Task::Inventory::Input::Win32::Drives;

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

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

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

        $object->{FreeSpace} = int($object->{FreeSpace} / (1024 * 1024))
            if $object->{FreeSpace};

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $inventory->addEntry(
            section => 'DRIVES',
            entry   => {
                CREATEDATE  => $object->{InstallDate},
                DESCRIPTION => $object->{Description},
                FREE        => $object->{FreeSpace},
                FILESYSTEM  => $object->{FileSystem},
                LABEL       => $object->{VolumeName},
                LETTER      => $object->{DeviceID} || $object->{Caption},
                SERIAL      => $object->{VolumeSerialNumber},
                SYSTEMDRIVE => (lc($object->{DeviceID}) eq $systemDrive),
                TOTAL       => $object->{Size},
                TYPE        => $type[$object->{DriveType}],
                VOLUMN      => $object->{VolumeName},
            }
        );
    }
}

1;
