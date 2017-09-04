package FusionInventory::Agent::Task::Inventory::Win32::Printers;

use strict;
use warnings;

use English qw(-no_match_vars);
use Storable 'dclone';

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

    return !$params{no_category}->{printer};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};

    foreach my $object (getWMIObjects(
        %$wmiParams,
        class      => 'Win32_Printer',
        properties => [ qw/
            ExtendedDetectedErrorState HorizontalResolution VerticalResolution Name
            Comment Description DriverName PortName Network Shared PrinterStatus
            ServerName ShareName PrintProcessor
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

        $object->{Serial} = _getUSBPrinterSerial($object->{PortName}, $logger, $wmiParams)
            if $object->{PortName} && $object->{PortName} =~ /USB/;

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

sub _getUSBPrinterSerial {
    my ($portName, $logger, $wmiParams) = @_;

    # the serial number can be extracted from the USB registry key, containing
    # all USB devices, but we only know the USB port identifier, meaning we
    # must first look in USBPRINT registry key, containing USB printers only,
    # and find some way to correlate entries
    my $usbprint_key = getRegistryKey(
        %$wmiParams,
        retrieveValuesForAllKeys => 1,
        path   => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Enum/USBPRINT",
        logger => $logger
    );

    my $usb_key = getRegistryKey(
        %$wmiParams,
        retrieveValuesForAllKeys => 1,
        path   => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Enum/USB",
        logger => $logger
    );

    # the ContainerID variable seems more reliable, but is not always available
    my $containerId = _getUSBContainerID($usbprint_key, $portName, $wmiParams);
    if ($containerId) {
        my $serial = _getUSBSerialFromContainerID($usb_key, $containerId, $wmiParams);
        return $serial if $serial;
    }

    # fallback on ParentIdPrefix variable otherwise
    my $prefix = _getUSBPrefix($usbprint_key, $portName, $wmiParams);
    if ($prefix) {
        my $serial = _getUSBSerialFromPrefix($usb_key, $prefix, $wmiParams);
        return $serial if $serial;
    }

    # bad luck
    return;
}

sub _getUSBContainerID {
    my ($print, $portName, $wmiParams) = @_;

    return ($wmiParams && $wmiParams->{WMIService}) ?
        _getUSBContainerIDFromRemote($print, $portName) :
        _getUSBContainerIDFromLocal($print, $portName);
}

sub _getUSBContainerIDFromRemote {
    my ($print, $portName) = @_;

    # registry data structure:
    # USBPRINT
    # └── device
    #     └── subdevice
    #         └── ContainerID:value
    #         └── Device Parameters
    #             └── PortName:value

    foreach my $device (values %$print) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'Device Parameters'}                &&
                    $subdevice->{'Device Parameters'}->{'PortName'} &&
                    $subdevice->{'Device Parameters'}->{'PortName'} eq $portName;
            # got it
            return $subdevice->{'ContainerID'};
        };
    }

    return;
}


sub _getUSBContainerIDFromLocal {
    my ($print, $portName) = @_;

    # registry data structure:
    # USBPRINT
    # └── device
    #     └── subdevice
    #         └── ContainerID:value
    #         └── Device Parameters
    #             └── PortName:value

    foreach my $device (values %$print) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'Device Parameters/'}                &&
                $subdevice->{'Device Parameters/'}->{'/PortName'} &&
                $subdevice->{'Device Parameters/'}->{'/PortName'} eq $portName;
            # got it
            return $subdevice->{'/ContainerID'};
        };
    }

    return;
}

sub _getUSBPrefix {
    my ($print, $portName, $wmiParams) = @_;

    return ($wmiParams && $wmiParams->{WMIService}) ?
        _getUSBPrefixFromRemote($print, $portName) :
        _getUSBPrefixFromLocal($print, $portName);
}

sub _getUSBPrefixFromRemote {
    my ($print, $portName) = @_;

    # registry data structure:
    # USBPRINT
    # └── device
    #     └── subdevice
    #         └── Device Parameters
    #             └── PortName:value

    foreach my $device (values %$print) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'Device Parameters'}                &&
                    $subdevice->{'Device Parameters'}->{'PortName'} &&
                    $subdevice->{'Device Parameters'}->{'PortName'} eq $portName;
            # got it
            my $prefix = $subdeviceName;
            $prefix =~ s{&$portName/$}{};
            return $prefix;
        };
    }

    return;
}

sub _getUSBPrefixFromLocal {
    my ($print, $portName) = @_;

    # registry data structure:
    # USBPRINT
    # └── device
    #     └── subdevice
    #         └── Device Parameters
    #             └── PortName:value

    foreach my $device (values %$print) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'Device Parameters/'}                &&
                $subdevice->{'Device Parameters/'}->{'/PortName'} &&
                $subdevice->{'Device Parameters/'}->{'/PortName'} eq $portName;
            # got it
            my $prefix = $subdeviceName;
            $prefix =~ s{&$portName/$}{};
            return $prefix;
        };
    }

    return;
}

sub _getUSBSerialFromPrefix {
    my ($usb, $prefix, $wmiParams) = @_;

    return ($wmiParams && $wmiParams->{WMIService}) ?
        _getUSBSerialFromPrefixFromRemote($usb, $prefix) :
        _getUSBSerialFromPrefixFromLocal($usb, $prefix);
}

sub _getUSBSerialFromPrefixFromRemote {
    my ($usb, $prefix) = @_;

    # registry data structure:
    # USB
    # └── device
    #     └── subdevice
    #         └── ParentIdPrefix:value

    foreach my $device (values %$usb) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'ParentIdPrefix'} &&
                    $subdevice->{'ParentIdPrefix'} eq $prefix;
            # got it
            my $serial = $subdeviceName;
            # pseudo serial generated by windows
            return if $serial =~ /&/;
            $serial =~ s{/$}{};
            return $serial;
        }
    }

    return;
}
sub _getUSBSerialFromPrefixFromLocal {
    my ($usb, $prefix) = @_;

    # registry data structure:
    # USB
    # └── device
    #     └── subdevice
    #         └── ParentIdPrefix:value

    foreach my $device (values %$usb) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'/ParentIdPrefix'} &&
                $subdevice->{'/ParentIdPrefix'} eq $prefix;
            # got it
            my $serial = $subdeviceName;
            # pseudo serial generated by windows
            return if $serial =~ /&/;
            $serial =~ s{/$}{};
            return $serial;
        }
    }

    return;
}

sub _getUSBSerialFromContainerID {
    my ($usb, $containerId, $wmiParams) = @_;

    return ($wmiParams && $wmiParams->{WMIService}) ?
        _getUSBSerialFromContainerIDFromRemote($usb, $containerId) :
        _getUSBSerialFromContainerIDFromLocal($usb, $containerId);
}

sub _getUSBSerialFromContainerIDFromRemote {
    my ($usb, $containerId) = @_;

    # registry data structure:
    # USB
    # └── device
    #     └── subdevice
    #         └── ContainerId:value

    foreach my $device (values %$usb) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'ContainerID'} &&
                    $subdevice->{'ContainerID'} eq $containerId;
            # pseudo serial generated by windows
            next if $subdeviceName =~ /&/;
            # got it
            my $serial = $subdeviceName;
            $serial =~ s{/$}{};
            return $serial;
        }
    }

    return;
}

sub _getUSBSerialFromContainerIDFromLocal {
    my ($usb, $containerId) = @_;

    # registry data structure:
    # USB
    # └── device
    #     └── subdevice
    #         └── ContainerId:value

    foreach my $device (values %$usb) {
        foreach my $subdeviceName (keys %$device) {
            my $subdevice = $device->{$subdeviceName};
            next unless
                $subdevice->{'/ContainerID'} &&
                $subdevice->{'/ContainerID'} eq $containerId;
            # pseudo serial generated by windows
            next if $subdeviceName =~ /&/;
            # got it
            my $serial = $subdeviceName;
            $serial =~ s{/$}{};
            return $serial;
        }
    }

    return;
}

1;
