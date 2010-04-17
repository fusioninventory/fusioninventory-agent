package FusionInventory::Agent::Task::Inventory::OS::Win32::Printers;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

my @status = (
        'Unknown', # 0 is not defined
        'Other',
        'Unknown',
        'Idle',
        'Printing',
        'Warming Up',
        'Stopped printing',
        'Offline',
        );

my @errStatus = (
        'Unknown',
        'Other',
        'No Error',
        'Low Paper',
        'No Paper',
        'Low Toner',
        'No Toner',
        'Door Open',
        'Jammed',
        'Service Requested',
        'Output Bin Full',
        'Paper Problem',
        'Cannot Print Page',
        'User Intervention Required',
        'Out of Memory',
        'Server Unknown',
        );


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


    my @slots;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_Printer' ) ) )
    {


        my $errStatus;
        if ($Properties->{ExtendedDetectedErrorState}) {
            $errStatus = $errStatus[$Properties->{ExtendedDetectedErrorState}];
        }
        $inventory->addPrinter({
                NAME => $Properties->{Name},
                DESCRIPTION => $Properties->{Description},
                DRIVER => $Properties->{DriverName},
                PORT => $Properties->{PortName},
                NETWORK => $Properties->{Network},
                SHARED => $Properties->{Shared},
                STATUS => $status[$Properties->{PrinterStatus}],
                ERRSTATUS => $errStatus,
                SERVERNAME => $Properties->{ServerName},
                SHARENAME => $Properties->{ShareName},
                PRINTPROCESSOR => $Properties->{PrintProcessor},
                });

    }    
}
1;
