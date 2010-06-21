package FusionInventory::Agent::Task::Inventory::OS::Win32::Controller;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub getPciIDFromDeviceID {
    my ($DeviceID) = @_;

    if ($DeviceID =~ /PCI\\VEN_(\S+)&DEV_(\S+)&SUBSYS_(\S+)/) {
# We ignore the subsystem for now
        return $1.':'.$2;
    }
}

my %seen;

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};

    foreach my $wmiClass (qw/
            Win32_FloppyController Win32_IDEController Win32_SCSIController
            Win32_VideoController
            Win32_InfraredDevice Win32_USBController Win32_1394Controller
            Win32_PCMCIAController CIM_LogicalDevice/) {

        foreach my $Properties
            (getWmiProperties($wmiClass,
qw/Name Manufacturer Caption Description DeviceID HardwareVersion/)) {

            my $pciid = getPciIDFromDeviceID($Properties->{DeviceID});

# I scan CIM_LogicalDevice to identify more devices but I don't want
# everything. Only devices with a PCIID sounds resonable
            if ($wmiClass eq 'CIM_LogicalDevice') {
                next unless $pciid;
                next if $seen{$pciid};
            }

            $seen{$pciid} = 1;

            $inventory->addController({
                    NAME => $Properties->{Name},
                    MANUFACTURER => $Properties->{Manufacturer},
                    CAPTION => $Properties->{Caption},
                    DESCRIPTION => $Properties->{Description},
                    PCIID => $pciid,
                    VERSION => $Properties->{HardwareVersion},
                    TYPE => $Properties->{Caption},
                    });

        }
    }


}
1;
