package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return can_run("hdparm");
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};



    my @hdparmDisks;
    my @hdparmCdroms;

    foreach my $l ('a'..'z') {
        my $disk;
        foreach (`hdparm -I /dev/hd$l 2>&1`) {
            $disk->{model} = $1 if /Model Number:\s+(\S*)/;
            $disk->{firmware} = $1 if /Firmware Revision:\s+(\S*)/;
            $disk->{serial} = $1 if /Serial Number:\s+(\S*)/;
            $disk->{size} = $1 if /1000:\s+(\d*)\sMBytes\s\(/;
        }
        push @hdparmDisks, $disk if keys %$disk;
    }


    foreach my $n (0..9) {
        my $cdrom;
        foreach (`hdparm -I /dev/scd$n 2>&1`) {
            $cdrom->{model} = $1 if /Model Number:\s+(\S*)/;
            $cdrom->{firmware} = $1 if /Firmware Revision:\s+(\S*)/;
            $cdrom->{serial} = $1 if /Serial Number:\s+(\S*)/;
        }
        push @hdparmCdroms, $cdrom if keys %$cdrom;

    }



    my $cpt=0;
    my @storages;
    foreach my $Properties
        (getWmiProperties('Win32_DiskDrive',
                          qw/Name Manufacturer Model MediaType InterfaceType FirmwareRevision
                          SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {

            my $hdparmDisk = $hdparmDisks[$cpt];

            $inventory->addStorage({
                MANUFACTURER => $Properties->{Manufacturer},
                             MODEL => $hdparmDisk->{model} || $Properties->{Model},
                             DESCRIPTION => $Properties->{Description},
                             NAME => $Properties->{Name},
                             TYPE => $Properties->{MediaType},
                             INTERFACE => $Properties->{InterfaceType},
                             FIRMWARE => $hdparmDisk->{firmware} || $Properties->{FirmwareRevision},
                             SERIAL => $hdparmDisk->{serial} || $Properties->{SerialNumber},
                             DISKSIZE => $hdparmDisk->{size} || int($Properties->{Size}/(1024*1024)),
                             SCSI_CHID => $Properties->{SCSILogicialUnit},
                             SCSI_COID => $Properties->{SCSIPort},
                             SCSI_LUN => $Properties->{SCSILogicalUnit},
                             SCSI_UNID => $Properties->{SCSITargetId},
            });

            $cpt++;
        }


    $cpt=0;
    foreach my $Properties
        (getWmiProperties('Win32_CDROMDrive',
                          qw/Manufacturer Caption Description Name MediaType InterfaceType FirmwareRevision
                          SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {

            my $hdparmCdrom = $hdparmCdroms[$cpt];

            $inventory->addStorage({
                MANUFACTURER => $Properties->{Manufacturer},
                MODEL => $hdparmCdrom->{model} || $Properties->{Caption},
                DESCRIPTION => $Properties->{Description},
                NAME => $Properties->{Name},
                TYPE => $Properties->{MediaType},
                INTERFACE => $Properties->{InterfaceType},
                FIRMWARE => $hdparmCdrom->{firmware} || $Properties->{FirmwareRevision},
                SERIAL => $hdparmCdrom->{serial} || $Properties->{SerialNumber},
                DISKSIZE => $hdparmCdrom->{size} || int($Properties->{Size}/(1024*1024)),
                SCSI_CHID => $Properties->{SCSILogicialUnit},
                SCSI_COID => $Properties->{SCSIPort},
                SCSI_LUN => $Properties->{SCSILogicalUnit},
                SCSI_UNID => $Properties->{SCSITargetId},
            });

            $cpt++;
        }

    foreach my $Properties
        (getWmiProperties('Win32_TapeDrive',
                          qw/Manufacturer Caption Description Name MediaType InterfaceType FirmwareRevision
                          SerialNumber Size SCSILogicialUnit SCSIPort SCSILogicalUnit SCSITargetId/)) {

            $inventory->addStorage({
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
            });

    }

}
1;
