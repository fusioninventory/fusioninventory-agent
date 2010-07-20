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
    foreach my $Properties (getWmiProperties('Win32_SerialPort', qw/
        Name Caption Description
    /)) {
        $inventory->addPorts({
            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Serial',
        });
    }

    foreach my $Properties (getWmiProperties('Win32_ParallelPort', qw/
        Name Caption Description
    /)) {

        $inventory->addPorts({
            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},
            TYPE => 'Parallel',
        });
    }



    # cf http://msdn.microsoft.com/en-us/library/aa394486%28VS.85%29.aspx
    my @portType = (
        'Unknown',
        'Other',
        'Male',
        'Female',
        'Shielded',
        'Unshielded',
        'SCSI (A) High-Density (50 pins)',
        'SCSI (A) Low-Density (50 pins)',
        'SCSI (P) High-Density (68 pins)',
        'SCSI SCA-I (80 pins)',
        'SCSI SCA-II (80 pins)',
        'SCSI Fibre Channel (DB-9, Copper)',
        'SCSI Fibre Channel (Fibre)',
        'SCSI Fibre Channel SCA-II (40 pins)',
        'SCSI Fibre Channel SCA-II (20 pins)',
        'SCSI Fibre Channel BNC',
        'ATA 3-1/2 Inch (40 pins)',
        'ATA 2-1/2 Inch (44 pins)',
        'ATA-2',
        'ATA-3',
        'ATA/66',
        'DB-9',
        'DB-15',
        'DB-25',
        'DB-36',
        'RS-232C',
        'RS-422',
        'RS-423',
        'RS-485',
        'RS-449',
        'V.35',
        'X.21',
        'IEEE-488',
        'AUI',
        'UTP Category 3',
        'UTP Category 4',
        'UTP Category 5',
        'BNC',
        'RJ11',
        'RJ45',
        'Fiber MIC',
        'Apple AUI',
        'Apple GeoPort',
        'PCI',
        'ISA',
        'EISA',
        'VESA',
        'PCMCIA',
        'PCMCIA Type I',
        'PCMCIA Type II',
        'PCMCIA Type III',
        'ZV Port',
        'CardBus',
        'USB',
        'IEEE 1394',
        'HIPPI',
        'HSSDC (6 pins)',
        'GBIC',
        'DIN',
        'Mini-DIN',
        'Micro-DIN',
        'PS/2',
        'Infrared',
        'HP-HIL',
        'Access.bus',
        'NuBus',
        'Centronics',
        'Mini-Centronics',
        'Mini-Centronics Type-14',
        'Mini-Centronics Type-20',
        'Mini-Centronics Type-26',
        'Bus Mouse',
        'ADB',
        'AGP',
        'VME Bus',
        'VME64',
        'Proprietary',
        'Proprietary Processor Card Slot',
        'Proprietary Memory Card Slot',
        'Proprietary I/O Riser Slot',
        'PCI-66MHZ',
        'AGP2X',
        'AGP4X',
        'PC-98',
        'PC-98-Hireso',
        'PC-H98',
        'PC-98Note',
        'PC-98Full',
        'PCI-X',
        'SSA SCSI',
        'Circular',
        'On-Board IDE Connector',
        'On-Board Floppy Connector',
        '9 Pin Dual Inline',
        '25 Pin Dual Inline',
        '50 Pin Dual Inline',
        '68 Pin Dual Inline',
        'On-Board Sound Connector',
        'Mini-Jack',
        'PCI-X',
        'Sbus IEEE 1396-1993 32 Bit',
        'Sbus IEEE 1396-1993 64 Bit',
        'MCA',
        'GIO',
        'XIO',
        'HIO',
        'NGIO',
        'PMC',
        'MTRJ',
        'VF-45',
        'Future I/O',
        'SC',
        'SG',
        'Electrical',
        'Optical',
        'Ribbon',
        'GLM',
        '1x9',
        'Mini SG',
        'LC',
        'HSSC',
        'VHDCI Shielded (68 pins)',
        'InfiniBand',
        'AGP8X',
        'PCI-E',
    );

    foreach my $Properties (getWmiProperties('Win32_PortConnector', qw/
        ConnectorType InternalReferenceDesignator
    /)) {

        my $type;
        if ($Properties->{ConnectorType}) {
            $type = join(', ', map { $portType[$_] } @{$Properties->{ConnectorType}}); 
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
