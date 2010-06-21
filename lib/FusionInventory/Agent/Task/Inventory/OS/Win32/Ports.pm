package FusionInventory::Agent::Task::Inventory::OS::Win32::Ports;

use strict;
use warnings;

# Had never been tested.
use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};


    my @ports;
    foreach my $Properties
        (getWmiProperties('Win32_SerialPort',
qw/Name Caption Description/)) {


        $inventory->addPorts({

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Serial',

        });

    }

    foreach my $Properties
        (getWmiProperties('Win32_ParallelPort',
qw/Name Caption Description/)) {

        $inventory->addPorts({

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Parallel',

        });

    }



    my @portType = (
            undef,
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

    foreach my $Properties
        (FusionInventory::Agent::Task::Inventory::OS::Win32::getWmiProperties('Win32_PortConnector',
qw/ConnectorType InternalReferenceDesignator/)) {

        my $type;
        if ($Properties->{ConnectorType}) {
            $type = $portType[$Properties->{ConnectorType}]; 
        }
        if (!$type) {
            $type = $Properties->{InternalReferenceDesignator};
            $type =~ s/\ \d.*//; # Drop the port number
        }

        if(!$type && !$Properties->{InternalReferenceDesignator}) {
            next;
        } elsif($Properties->{InternalReferenceDesignator} =~ /SERIAL/) {
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
