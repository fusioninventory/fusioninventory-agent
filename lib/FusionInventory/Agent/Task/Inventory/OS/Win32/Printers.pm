package FusionInventory::Agent::Task::Inventory::OS::Win32::Printers;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

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

sub isEnabled {
    my (%params) = @_;
    return !$params{no_printer};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_Printer',
        properties => [ qw/
            ExtendedDetectedErrorState HorizontalResolution VerticalResolution Name
            Comment DescriptionDriverName DriverName PortName Network Shared 
            PrinterStatus ServerName ShareName PrintProcessor
        / ]
    )) {

        my $errStatus;
        if ($object->{ExtendedDetectedErrorState}) {
            $errStatus = $errStatus[$object->{ExtendedDetectedErrorState}];
        }

        my $resolution;

        if ($object->{HorizontalResolution}) {
            $resolution =
                $object->{HorizontalResolution} .
                "x"                             .
                $object->{VerticalResolution};
        }

        $object->{Serial} = _getSerialbyUsb($object->{PortName});

        $inventory->addEntry(
            section => 'PRINTERS',
            entry   => {
                NAME           => $object->{Name},
                COMMENT        => $object->{Comment},
                DESCRIPTION    => $object->{Description},
                DRIVER         => $object->{DriverName},
                PORT           => $object->{PortName},
                RESOLUTION     => $resolution,
                NETWORK        => $object->{Network},
                SHARED         => $object->{Shared},
                STATUS         => $status[$object->{PrinterStatus}],
                ERRSTATUS      => $errStatus,
                SERVERNAME     => $object->{ServerName},
                SHARENAME      => $object->{ShareName},
                PRINTPROCESSOR => $object->{PrintProcessor},
                SERIAL         => $object->{Serial}
            }
        );

    }    
}

# Search serial when connected in USB
sub _getSerialbyUsb {
    my ($portName) = @_;

    return unless $portName && $portName =~ /USB/;

    my $machKey = $Registry->Open('LMachine', { 
        Access => KEY_READ | KEY_WOW64_64 ## no critic (ProhibitBitwise)
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    # search all keys under HKLM\system\currentcontrolset\enum\USBPRINT
    my $data = $machKey->{"SYSTEM/CurrentControlSet/Enum/USBPRINT"};
    foreach my $tmpkey (%$data) {
        next unless ref($tmpkey) eq "Win32::TieRegistry";

       # search a subkey whose name contains the port number (USBxxx)
       foreach my $usbid (%$tmpkey) {
           next unless $usbid =~ /$portName/;

            # get its container id
            $usbid = $tmpkey->{$usbid}->{"ContainerID"};
            my $serialnumber = "";

            # search all keys under HKLM\system\currentcontrolset\enum\USB
            my $dataUSB = $machKey->{"SYSTEM/CurrentControlSet/Enum/USB"};
            foreach my $tmpkeyUSB (%$dataUSB) {
                next unless ref($tmpkeyUSB) eq "Win32::TieRegistry";

                # search a subkey matching this container id
                foreach my $serialtmp (%$tmpkeyUSB) {
                    if (ref($serialtmp) eq "Win32::TieRegistry") {
                        foreach my $regkeys (%$serialtmp) {
                            next unless defined($regkeys) &&
                                ref($regkeys) ne "Win32::TieRegistry";
                            next unless $regkeys =~ /ContainerID/;
                            next if $serialnumber =~ /\&/;
                            next unless defined($serialnumber);
                            next unless $serialtmp->{$regkeys} eq $usbid;
                            return $serialnumber;
                        }
                    } else {
                        $serialnumber = $serialtmp;
                    }
                }
            }
        }
    }
    return;
}

1;
