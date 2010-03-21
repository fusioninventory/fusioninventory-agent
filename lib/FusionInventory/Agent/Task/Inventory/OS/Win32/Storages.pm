package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }


    my @storages;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_DiskDrive' ) ) )
    {

        push @storages, {
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            MODEL => encode('UTF-8', $Properties->{Model}),
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

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_CDROMDrive' ) ) )
    {

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

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_TapeDrive' ) ) )
    {

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
