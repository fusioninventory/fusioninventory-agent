package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('hdparm');
}

sub getInfo {
    my ($type, $nbr) = @_;

    my $info = {};

    my $device = "/dev/";
    $device .= $type eq 'hd'?'hd':'scd';
    $device .= chr(ord('a')+$nbr);

    foreach (`hdparm -I $device 2>&1`) {
        $info->{model} = $1 if /Model Number:\s+(.*?)\s*$/;
        $info->{firmware} = $1 if /Firmware Revision:\s+(\S*)/;
        $info->{serial} = $1 if /Serial Number:\s+(\S*)/;
        $info->{size} = $1 if /1000:\s+(\d*)\sMBytes\s\(/;
    }

    return $info;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_DiskDrive', 
        properties => [ qw/
            Name Manufacturer Model MediaType InterfaceType FirmwareRevision
            SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        my $info = {};

        if ($object->{Name} =~ /(\d+)$/) {
            $info = getInfo("hd", $1);
        }

        $inventory->addStorage({
            MANUFACTURER => $object->{Manufacturer},
            MODEL        => $info->{model} || $object->{Model},
            DESCRIPTION  => $object->{Description},
            NAME         => $object->{Name},
            TYPE         => $object->{MediaType},
            INTERFACE    => $object->{InterfaceType},
            FIRMWARE     => $info->{firmware} || $object->{FirmwareRevision},
            SERIAL       => $info->{serial} || $object->{SerialNumber},
            DISKSIZE     => $info->{size} || int($object->{Size}/(1024*1024)),
            SCSI_CHID    => $object->{SCSILogicialUnit},
            SCSI_COID    => $object->{SCSIPort},
            SCSI_LUN     => $object->{SCSILogicalUnit},
            SCSI_UNID    => $object->{SCSITargetId},
        });
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_CDROMDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
            SCSILogicalUnit SCSITargetId
        / ]
    )) {
        my $info = {};

        if ($object->{Name} =~ /(\d+)$/) {
            $info = getInfo("cdrom", $1);
        }

        my $size;
        if ($object->{Size}) {
            $size = int($object->{Size}/(1024*1024))
        }

        $inventory->addStorage({
            MANUFACTURER => $object->{Manufacturer},
            MODEL        => $info->{model} || $object->{Caption},
            DESCRIPTION  => $object->{Description},
            NAME         => $object->{Name},
            TYPE         => $object->{MediaType},
            INTERFACE    => $object->{InterfaceType},
            FIRMWARE     => $info->{firmware} || $object->{FirmwareRevision},
            SERIAL       => $info->{serial} || $object->{SerialNumber},
            DISKSIZE     => $info->{size} || $size,
            SCSI_CHID    => $object->{SCSILogicialUnit},
            SCSI_COID    => $object->{SCSIPort},
            SCSI_LUN     => $object->{SCSILogicalUnit},
            SCSI_UNID    => $object->{SCSITargetId},
        });
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_TapeDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
            SCSILogicalUnit SCSITargetId
        / ]
    )) {

        $inventory->addStorage({
            MANUFACTURER => $object->{Manufacturer},
            MODEL        => $object->{Caption},
            DESCRIPTION  => $object->{Description},
            NAME         => $object->{Name},
            TYPE         => $object->{MediaType},
            INTERFACE    => $object->{InterfaceType},
            FIRMWARE     => $object->{FirmwareRevision},
            SERIAL       => $object->{SerialNumber},
            DISKSIZE     => int($object->{Size}/(1024*1024)),
            SCSI_CHID    => $object->{SCSILogicialUnit},
            SCSI_COID    => $object->{SCSIPort},
            SCSI_LUN     => $object->{SCSILogicalUnit},
            SCSI_UNID    => $object->{SCSITargetId},
        });

    }

}
1;
