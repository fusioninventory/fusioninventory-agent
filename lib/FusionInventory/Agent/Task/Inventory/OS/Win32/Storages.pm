package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use strict;

sub isInventoryEnabled {1}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};


    my @storages;
        foreach my $Properties
            (getWmiProperties('Win32_DiskDrive',
qw/Name Manufacturer Model MediaType InterfaceType FirmwareRevision
SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {

        push @storages, {
            MANUFACTURER => $Properties->{Manufacturer},
            MODEL => $Properties->{Model},
            DESCRIPTION => $Properties->{Description},
            NAME => $Properties->{Name},
            TYPE => $Properties->{MediaType},
            INTERFACE => $Properties->{InterfaceType},
            FIRMWARE => $Properties->{FirmwareRevision},
            SERIAL => $Properties->{SerialNumber},
            DISKSIZE => int($Properties->{Size}/(1024*1024)),
            SCSI_CHID => $Properties->{SCSILogicialUnit},
            SCSI_COID => $Properties->{SCSIPort},
            SCSI_LUN => $Properties->{SCSILogicalUnit},
            SCSI_UNID => $Properties->{SCSITargetId},
        };

    }


        foreach my $Properties
            (getWmiProperties('Win32_CDROMDrive',
qw/Manufacturer Caption Description Name MediaType InterfaceType FirmwareRevision
SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {


        push @storages, {
            MANUFACTURER => $Properties->{Manufacturer},
            MODEL => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            NAME => $Properties->{Name},
            TYPE => $Properties->{MediaType},
            INTERFACE => $Properties->{InterfaceType},
            FIRMWARE => $Properties->{FirmwareRevision},
            SERIAL => $Properties->{SerialNumber},
            DISKSIZE => int($Properties->{Size}/(1024*1024)),
            SCSI_CHID => $Properties->{SCSILogicialUnit},
            SCSI_COID => $Properties->{SCSIPort},
            SCSI_LUN => $Properties->{SCSILogicalUnit},
            SCSI_UNID => $Properties->{SCSITargetId},
        };

    }

        foreach my $Properties
            (getWmiProperties('Win32_TapeDrive',
qw/Manufacturer Caption Description Name MediaType InterfaceType FirmwareRevision
SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {

        push @storages, {
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            MODEL => encode('UTF-8', $Properties->{Caption}),
            DESCRIPTION => encode('UTF-8', $Properties->{Description}),
            NAME => encode('UTF-8', $Properties->{Name}),
            TYPE => encode('UTF-8', $Properties->{MediaType}),
            INTERFACE => $Properties->{InterfaceType},
            FIRMWARE => $Properties->{FirmwareRevision},
            SERIAL => $Properties->{SerialNumber},
            DISKSIZE => int($Properties->{Size}/(1024*1024)),
            SCSI_CHID => $Properties->{SCSILogicialUnit},
            SCSI_COID => $Properties->{SCSIPort},
            SCSI_LUN => $Properties->{SCSILogicalUnit},
            SCSI_UNID => $Properties->{SCSITargetId},
        };

    }


    foreach (@storages) {
        $inventory->addStorages($_);
    }

}
1;
