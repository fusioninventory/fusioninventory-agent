package FusionInventory::Agent::Task::Inventory::OS::Win32::Controller;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use 
FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers;

sub isInventoryEnabled {
    return 1;
}

sub getPciIDFromDeviceID {
    my ($DeviceID) = @_;

    my $pciid;
    my$pcisubsystemid;

    if ($DeviceID =~ /PCI\\VEN_(\S{4})&DEV_(\S{4})/) {
        $pciid = lc($1.':'.$2);
    }

    if ($DeviceID =~ /&SUBSYS_(\S{4})(\S{4})/) {
        $pcisubsystemid = lc($2.':'.$1);
    }

    return ($pciid, $pcisubsystemid);
}

my %seen;

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};
    my $logger = $params->{logger};
    my $config = $params->{config};

    foreach my $wmiClass (qw/
            Win32_FloppyController Win32_IDEController Win32_SCSIController
            Win32_VideoController
            Win32_InfraredDevice Win32_USBController Win32_1394Controller
            Win32_PCMCIAController CIM_LogicalDevice/) {

        foreach my $Properties
            (getWmiProperties($wmiClass,
qw/Name Manufacturer Caption Description DeviceID HardwareVersion/)) {

            my ($pciid, $pcisubsystemid) = getPciIDFromDeviceID($Properties->{DeviceID});


# I scan CIM_LogicalDevice to identify more devices but I don't want
# everything. Only devices with a PCIID sounds resonable
            if ($wmiClass eq 'CIM_LogicalDevice') {
                next unless $pciid;
                next if $seen{$pciid};
            }

            my $info =
FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers::getInfoFromPciIds ({
                    config => $config,
                    logger => $logger,
#                    pciclass => $pciclass,
                    pciid => $pciid,
                    pcisubsystemid => $pcisubsystemid,
                });

use Data::Dumper;
print Dumper($info);
            if($pciid) {
                $seen{$pciid} = 1;
            }
            $inventory->addController({
                    NAME => $info->{deviceName} || $Properties->{Name},
                    MANUFACTURER => $info->{vendorName} || $Properties->{Manufacturer},
                    CAPTION => $info->{deviceName} || $Properties->{Caption},
                    DESCRIPTION => $Properties->{Description},
                    PCIID => $pciid,
                    'PCISUBSYSTEMID'=> $pcisubsystemid,
                    VERSION => $Properties->{HardwareVersion},
                    TYPE => $Properties->{Caption},
                    });

        }
    }


}
1;
