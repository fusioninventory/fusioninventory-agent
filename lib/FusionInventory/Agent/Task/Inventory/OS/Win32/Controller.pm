package FusionInventory::Agent::Task::Inventory::OS::Win32::Controller;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};
    my %seen;

    foreach my $class (qw/
        Win32_FloppyController Win32_IDEController Win32_SCSIController
        Win32_VideoController Win32_InfraredDevice Win32_USBController
        Win32_1394Controller Win32_PCMCIAController CIM_LogicalDevice
    /) {

        foreach my $object (getWmiObjects(
            class      => $class,
            properties => [ qw/
                Name Manufacturer Caption Description DeviceID HardwareVersion
            /] 
        )) {

            my ($pciid, $pcisubsystemid) = _getPciIDFromDeviceID(
                $object->{DeviceID}
            );

            # I scan CIM_LogicalDevice to identify more devices but I don't want
            # everything. Only devices with a PCIID sounds resonable
            if ($wmiClass eq 'CIM_LogicalDevice') {
                next unless $pciid;
                next if $seen{$pciid};
            }

            if ($pciid) {
                $seen{$pciid} = 1;
            }
            $inventory->addController({
                NAME           => $object->{Name},
                MANUFACTURER   => $object->{Manufacturer},
                CAPTION        => $object->{Caption},
                DESCRIPTION    => $object->{Description},
                PCIID          => $pciid,
                PCISUBSYSTEMID => $pcisubsystemid,
                VERSION        => $object->{HardwareVersion},
                TYPE           => $object->{Caption},
            });
        }
    }
}

sub _getPciIDFromDeviceID {
    my ($DeviceID) = @_;

    my $pciid;
    my $pcisubsystemid;

    if ($DeviceID =~ /PCI\\VEN_(\S{4})&DEV_(\S{4})/) {
        $pciid = lc($1.':'.$2);
    }

    if ($DeviceID =~ /&SUBSYS_(\S{4})(\S{4})/) {
        $pcisubsystemid = lc($2.':'.$1);
    }

    return ($pciid, $pcisubsystemid);
}

1;
