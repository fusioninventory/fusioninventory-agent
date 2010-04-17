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



    my @portType = (

            'None',
            'Parallel Port XT/AT Compatible',
            'Parallel Port PS/2',
            'Parallel Port ECP',
            'Parallel Port EPP',
            'Parallel Port ECP/EPP',
            'Serial Port XT/AT Compatible',
            'Serial Port 16450 Compatible',
            'Serial Port 16550 Compatible',
            'Serial Port 16550A Compatible',
            'SCSI Port',
            'MIDI Port',
            'Joy Stick Port',
            'Keyboard Port',
            'Mouse Port',
            'SSA SCSI ',
            'USB',
            'FireWire (IEEE P1394)',
            'PCMCIA Type II',
            'PCMCIA Type II',
            'PCMCIA Type III',
            'CardBus',
            'Access Bus Port',
            'SCSI II',
            'SCSI Wide',
            'PC-98',
            'PC-98-Hireso',
            'PC-H98',
            'Video Port',
            'Audio Port',
            'Modem Port',
            'Network Port',
            '8251 Compatible',
            '8251 FIFO Compatible',

            );

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_PortConnector' ) ) )
    {


        my $type;
        if ($Properties->{ConnectorType}) {
            $type = $portType[$Properties->{ConnectorType}]; 
        } else {
            $type = $Properties->{InternalReferenceDesignator};
            $type =~ s/\ \d.*//; # Drop the port number
        }

        if($Properties->{InternalReferenceDesignator} =~ /SERIAL/) {
            next; # Already done
        } elsif($Properties->{InternalReferenceDesignator} =~ /PARALLEL/) {
            next; # Already done
        }

        $inventory->addPorts({

            NAME => $Properties->{InternalReferenceDesignator},
            CAPTION => $Properties->{InternalReferenceDesignator},
            DESCRIPTION => $Properties->{InternalReferenceDesignator},
            TYPE => $type

        });

    }

}
1;
