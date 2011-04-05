package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return can_run('hdparm');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $Properties (getWmiProperties('Win32_DiskDrive', qw/
        Name Manufacturer Model MediaType InterfaceType FirmwareRevision
        SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId
    /)) {

        my $info = {};

        if ($Properties->{Name} =~ /(\d+)$/) {
            $info = _getInfo("hd", $1);
        }

        $inventory->addStorage({
            MANUFACTURER => $Properties->{Manufacturer},
            MODEL        => $info->{model} || $Properties->{Model},
            DESCRIPTION  => $Properties->{Description},
            NAME         => $Properties->{Name},
            TYPE         => $Properties->{MediaType},
            INTERFACE    => $Properties->{InterfaceType},
            FIRMWARE     => $info->{firmware} || $Properties->{FirmwareRevision},
            SERIAL       => $info->{serial} || $Properties->{SerialNumber},
            DISKSIZE     => $info->{size} || int($Properties->{Size}/(1024*1024)),
            SCSI_CHID    => $Properties->{SCSILogicialUnit},
            SCSI_COID    => $Properties->{SCSIPort},
            SCSI_LUN     => $Properties->{SCSILogicalUnit},
            SCSI_UNID    => $Properties->{SCSITargetId},
        });
    }

    foreach my $Properties (getWmiProperties('Win32_CDROMDrive', qw/
        Manufacturer Caption Description Name MediaType InterfaceType
        FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
        SCSILogicalUnit SCSITargetId
    /)) {
        my $info = {};

        if ($Properties->{Name} =~ /(\d+)$/) {
            $info = _getInfo("cdrom", $1);
        }

        my $size;
        if ($Properties->{Size}) {
            $size = int($Properties->{Size}/(1024*1024))
        }

        $inventory->addStorage({
            MANUFACTURER => $Properties->{Manufacturer},
            MODEL        => $info->{model} || $Properties->{Caption},
            DESCRIPTION  => $Properties->{Description},
            NAME         => $Properties->{Name},
            TYPE         => $Properties->{MediaType},
            INTERFACE    => $Properties->{InterfaceType},
            FIRMWARE     => $info->{firmware} || $Properties->{FirmwareRevision},
            SERIAL       => $info->{serial} || $Properties->{SerialNumber},
            DISKSIZE     => $info->{size} || $size,
            SCSI_CHID    => $Properties->{SCSILogicialUnit},
            SCSI_COID    => $Properties->{SCSIPort},
            SCSI_LUN     => $Properties->{SCSILogicalUnit},
            SCSI_UNID    => $Properties->{SCSITargetId},
        });
    }

    foreach my $Properties (getWmiProperties('Win32_TapeDrive', qw/
        Manufacturer Caption Description Name MediaType InterfaceType
        FirmwareRevision SerialNumber Size SCSILogicialUnit SCSIPort
        SCSILogicalUnit SCSITargetId
    /)) {

        $inventory->addStorage({
            MANUFACTURER => $Properties->{Manufacturer},
            MODEL        => $Properties->{Caption},
            DESCRIPTION  => $Properties->{Description},
            NAME         => $Properties->{Name},
            TYPE         => $Properties->{MediaType},
            INTERFACE    => $Properties->{InterfaceType},
            FIRMWARE     => $Properties->{FirmwareRevision},
            SERIAL       => $Properties->{SerialNumber},
            DISKSIZE     => int($Properties->{Size}/(1024*1024)),
            SCSI_CHID    => $Properties->{SCSILogicialUnit},
            SCSI_COID    => $Properties->{SCSIPort},
            SCSI_LUN     => $Properties->{SCSILogicalUnit},
            SCSI_UNID    => $Properties->{SCSITargetId},
        });

    }
}

sub _getInfo {
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

1;
