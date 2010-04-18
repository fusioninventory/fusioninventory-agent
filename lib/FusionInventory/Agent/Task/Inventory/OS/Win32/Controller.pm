package FusionInventory::Agent::Task::Inventory::OS::Win32::Controller;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
 
#Win32::OLE-> Option(CP=>CP_UTF8);
 
use Win32::OLE::Enum;

use Encode qw(encode);


sub isInventoryEnabled {1}

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

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

    foreach my $wmiClass (qw/
            Win32_FloppyController Win32_IDEController Win32_SCSIController
            Win32_VideoController
            Win32_InfraredDevice Win32_USBController Win32_1394Controller
            Win32_PCMCIAController CIM_LogicalDevice/) {

        foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                        $wmiClass ) ) )
        {

            my $pciid = getPciIDFromDeviceID($Properties->{DeviceID});

# I scan CIM_LogicalDevice to identify more devices but I don't want
# everything. Only devices with a PCIID sounds resonable
            if ($wmiClass eq 'CIM_LogicalDevice') {
                next unless $pciid;
                next if $seen{$pciid};
            }

            $seen{$pciid} = 1;

            $inventory->addController({
                    NAME => encode('UTF-8', $Properties->{Name}),
                    MANUFACTURER => encode('UTF-8',
                        $Properties->{Manufacturer}),
                    CAPTION => encode('UTF-8', $Properties->{Caption}),
                    DESCRIPTION => encode('UTF-8',
                        $Properties->{Description}),
                    PCIID => $pciid,
                    VERSION => $Properties->{HardwareVersion},
                    TYPE => encode('UTF-8', $Properties->{Caption}),
                    });

        }
    }


}
1;
