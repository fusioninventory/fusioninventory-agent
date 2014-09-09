package FusionInventory::Agent::Task::Inventory::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $hdparm = canRun('hdparm');

    foreach my $storage (_getDrives(class => 'Win32_DiskDrive')) {
        if ($hdparm && $storage->{NAME} =~ /(\d+)$/) {
            my $info = getHdparmsInfo(
                device => "/dev/hd" . chr(ord('a') + $1),
                logger => $logger
            );
            $storage->{MODEL}    = $info->{model}    if $info->{model};
            $storage->{FIRMWARE} = $info->{firmware} if $info->{firmware};
            $storage->{SERIAL}   = $info->{serial}   if $info->{serial};
            $storage->{DISKSIZE} = $info->{size}     if $info->{size};
        }

        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
        );
    }

    foreach my $storage (_getDrives(class => 'Win32_CDROMDrive')) {
        if ($hdparm && $storage->{NAME} =~ /(\d+)$/) {
            my $info = getHdparmsInfo(
                device => "/dev/scd" . chr(ord('a') + $1),
                logger => $logger
            );
            $storage->{MODEL}    = $info->{model}    if $info->{model};
            $storage->{FIRMWARE} = $info->{firmware} if $info->{firmware};
            $storage->{SERIAL}   = $info->{serial}   if $info->{serial};
            $storage->{DISKSIZE} = $info->{size}     if $info->{size};
        }

        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
        );
    }

    foreach my $storage (_getDrives(class => 'Win32_TapeDrive')) {
        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
        );
    }
}

sub _getDrives {
    my (%params) = @_;

    my @drives;

    foreach my $object (getWMIObjects(
        class      => $params{class},
        properties => [ qw/
            Manufacturer Model Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size
            SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        my $drive = {
            MANUFACTURER => $object->{Manufacturer},
            MODEL        => $object->{Model} || $object->{Caption},
            DESCRIPTION  => $object->{Description},
            NAME         => $object->{Name},
            TYPE         => $object->{MediaType},
            INTERFACE    => $object->{InterfaceType},
            FIRMWARE     => $object->{FirmwareRevision},
            SCSI_COID    => $object->{SCSIPort},
            SCSI_LUN     => $object->{SCSILogicalUnit},
            SCSI_UNID    => $object->{SCSITargetId},
        };

        $drive->{DISKSIZE} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $drive->{SERIAL} = $object->{SerialNumber}
            if $object->{SerialNumber} && $object->{SerialNumber} !~ /^ +$/;

        push @drives, $drive;
    }

    return @drives;
}

1;
