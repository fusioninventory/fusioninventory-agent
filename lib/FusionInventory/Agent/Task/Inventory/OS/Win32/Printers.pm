package FusionInventory::Agent::Task::Inventory::OS::Win32::Printers;

use strict;
use warnings;
use Data::Dumper;
use FusionInventory::Agent::Task::Inventory::OS::Win32;

use Win32::TieRegistry ( Delimiter=>"/", ArrayValues=>0 );

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


sub isInventoryEnabled {
    return 1;
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $config = $params->{config};
    my $inventory = $params->{inventory};

    return if $config->{'no-printer'};

    my @slots;

    foreach my $Properties
        (getWmiProperties('Win32_Printer',
qw/ExtendedDetectedErrorState HorizontalResolution VerticalResolution Name Comment DescriptionDriverName DriverName
 PortName Network Shared PrinterStatus ServerName ShareName PrintProcessor
/)) {

        my $errStatus;
        if ($Properties->{ExtendedDetectedErrorState}) {
            $errStatus = $errStatus[$Properties->{ExtendedDetectedErrorState}];
        }

        my $resolution;

        if ($Properties->{HorizontalResolution}) {
            $resolution =
$Properties->{HorizontalResolution}."x".$Properties->{VerticalResolution};
        }

        $Properties->{Serial} = getSerialbyUsb($Properties->{PortName});

        $inventory->addPrinter({
                NAME => $Properties->{Name},
                COMMENT => $Properties->{Comment},
                DESCRIPTION => $Properties->{Description},
                DRIVER => $Properties->{DriverName},
                PORT => $Properties->{PortName},
                RESOLUTION => $resolution,
                NETWORK => $Properties->{Network},
                SHARED => $Properties->{Shared},
                STATUS => $status[$Properties->{PrinterStatus}],
                ERRSTATUS => $errStatus,
                SERVERNAME => $Properties->{ServerName},
                SHARENAME => $Properties->{ShareName},
                PRINTPROCESSOR => $Properties->{PrintProcessor},
                SERIAL => $Properties->{Serial}
                });

    }    
}

sub getSerialbyUsb {

    my $portName = shift;

    if (!defined($portName)) {
        return;
    }
    if ($portName =~ /USB/) {
    } else {
        return;
    }

    # Search serial when connected in USB
    # Search in registry where folder in HKLM\system\currentcontrolset\enum\USBPRINT have USBxxx ($portName)
    my $KEY_WOW64_64KEY = 0x100;

    my $machKey= $Registry->Open( "LMachine", {Access=>Win32::TieRegistry::KEY_READ()|$KEY_WOW64_64KEY,Delimiter=>"/"} );
    my $data = $machKey->{"SYSTEM/CurrentControlSet/Enum/USBPRINT"};
    foreach my $tmpkey (%$data) {
        if (ref($tmpkey) eq "Win32::TieRegistry") {
            foreach my $usbid (%$tmpkey) {
                if ( $usbid =~ /$portName/) {
                    $usbid = $tmpkey->{$usbid}->{"ContainerID"};
                    my $serialnumber = "";
                    # search in HKLM\system\currentcontrolset\enum\USB the key with ContainerID to this value
                    # so previous folder name is serial number ^^
                    my $dataUSB = $machKey->{"SYSTEM/CurrentControlSet/Enum/USB"};
                    foreach my $tmpkeyUSB (%$dataUSB) {
                        if (ref($tmpkeyUSB) eq "Win32::TieRegistry") {
                            foreach my $serialtmp (%$tmpkeyUSB) {
                                if (ref($serialtmp) eq "Win32::TieRegistry") {
                                    foreach my $regkeys (%$serialtmp) {
                                        if ((defined($regkeys)) && (ref($regkeys) ne "Win32::TieRegistry")) {
                                            next unless $regkeys =~ /ContainerID/;
                                            if ($serialnumber =~ /\&/) {
                                            } elsif (defined($serialnumber)) {
                                                if ($serialtmp->{$regkeys} eq $usbid) {
                                                    return $serialnumber;
                                                }
                                            }
                                        }
                                    }
                                } else {

                                    $serialnumber = $serialtmp;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return;
}


1;
