package FusionInventory::Agent::Task::Inventory::Win32::Drives;

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
    foreach my $object (getWMIObjects(
        class      => 'Win32_OperatingSystem',
        properties => [ qw/SystemDrive/ ]
    )) {
        $systemDrive = lc($object->{SystemDrive});
    }

    foreach my $object (getWMIObjects(
        class      => 'Win32_LogicalDisk',
        properties => [ qw/
            InstallDate Description FreeSpace FileSystem VolumeName Caption
            VolumeSerialNumber DeviceID Size DriveType VolumeName ProviderName
        / ]
    )) {

        $object->{FreeSpace} = int($object->{FreeSpace} / (1024 * 1024))
            if $object->{FreeSpace};

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        my $filesystem = $object->{FileSystem};
        if ($object->{DriveType} == 4) {
            if ($object->{ProviderName} =~ /\\DavWWWRoot\\/) {
                $filesystem = "WebDav";
            } elsif (!$object->{FileSystem} || $object->{FileSystem} ne 'NFS') {
                $filesystem = "CIFS";
            }
        }


        $inventory->addEntry(
            section => 'DRIVES',
            entry   => {
                CREATEDATE  => $object->{InstallDate},
                DESCRIPTION => $object->{Description},
                FREE        => $object->{FreeSpace},
                FILESYSTEM  => $filesystem,
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
