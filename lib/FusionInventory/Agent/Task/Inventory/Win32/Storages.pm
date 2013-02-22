package FusionInventory::Agent::Task::Inventory::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return canRun('hdparm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWMIObjects(
        class      => 'Win32_DiskDrive',
        properties => [ qw/
            Name Manufacturer Model MediaType InterfaceType FirmwareRevision
            SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        my $info = {};

        if ($object->{Name} =~ /(\d+)$/) {
            $info = _getInfo("hd", $1);
        }

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $inventory->addEntry(
            section => 'STORAGES',
            entry => {
                MANUFACTURER => $object->{Manufacturer},
                MODEL        => $info->{model} || $object->{Model},
                DESCRIPTION  => $object->{Description},
                NAME         => $object->{Name},
                TYPE         => $object->{MediaType},
                INTERFACE    => $object->{InterfaceType},
                FIRMWARE     => $info->{firmware} || $object->{FirmwareRevision},
                SERIAL       => $info->{serial} || $object->{SerialNumber},
                DISKSIZE     => $info->{size} || $object->{Size},
                SCSI_CHID    => $object->{SCSILogicialUnit},
                SCSI_COID    => $object->{SCSIPort},
                SCSI_LUN     => $object->{SCSILogicalUnit},
                SCSI_UNID    => $object->{SCSITargetId},
            }
        );
    }

    foreach my $object (getWMIObjects(
        class      => 'Win32_CDROMDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
            SCSILogicalUnit SCSITargetId
        / ]
    )) {
        my $info = {};

        if ($object->{Name} =~ /(\d+)$/) {
            $info = _getInfo("cdrom", $1);
        }

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $inventory->addEntry(
            section => 'STORAGES',
            entry => {
                MANUFACTURER => $object->{Manufacturer},
                MODEL        => $info->{model} || $object->{Caption},
                DESCRIPTION  => $object->{Description},
                NAME         => $object->{Name},
                TYPE         => $object->{MediaType},
                INTERFACE    => $object->{InterfaceType},
                FIRMWARE     => $info->{firmware} || $object->{FirmwareRevision},
                SERIAL       => $info->{serial} || $object->{SerialNumber},
                DISKSIZE     => $info->{size} || $object->{Size},
                SCSI_CHID    => $object->{SCSILogicialUnit},
                SCSI_COID    => $object->{SCSIPort},
                SCSI_LUN     => $object->{SCSILogicalUnit},
                SCSI_UNID    => $object->{SCSITargetId},
            }
        );
    }

    foreach my $object (getWMIObjects(
        class      => 'Win32_TapeDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
            SCSILogicalUnit SCSITargetId
        / ]
    )) {

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $inventory->addEntry(
            section => 'STORAGES',
            entry => {
                MANUFACTURER => $object->{Manufacturer},
                MODEL        => $object->{Caption},
                DESCRIPTION  => $object->{Description},
                NAME         => $object->{Name},
                TYPE         => $object->{MediaType},
                INTERFACE    => $object->{InterfaceType},
                FIRMWARE     => $object->{FirmwareRevision},
                SERIAL       => $object->{SerialNumber},
                DISKSIZE     => $object->{Size},
                SCSI_CHID    => $object->{SCSILogicialUnit},
                SCSI_COID    => $object->{SCSIPort},
                SCSI_LUN     => $object->{SCSILogicalUnit},
                SCSI_UNID    => $object->{SCSITargetId},
            }
        );
    }
}

sub _getInfo {
    my ($type, $nbr) = @_;


    my $device = "/dev/";
    $device .= $type eq 'hd'?'hd':'scd';
    $device .= chr(ord('a')+$nbr);

    my $handle = getFileHandle(
        command => "hdparm -I $device",
    );
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        $info->{model} = $1 if $line =~ /Model Number:\s+(.*?)\s*$/;
        $info->{firmware} = $1 if $line =~ /Firmware Revision:\s+(\S*)/;
        $info->{serial} = $1 if $line =~ /Serial Number:\s+(\S*)/;
        $info->{size} = $1 if $line =~ /1000:\s+(\d*)\sMBytes\s\(/;
    }
    close $handle;

    return $info;
}

1;
