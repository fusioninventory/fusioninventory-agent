package FusionInventory::Agent::Task::Inventory::OS::Win32::Ports;
# Had never been tested.
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


    my @ports;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_SerialPort' ) ) )
    {


        $inventory->addPorts({

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Serial',

        });

    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_ParallelPort' ) ) )
    {


        $inventory->addPorts({

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Parallel',

        });

    }
}
1;
