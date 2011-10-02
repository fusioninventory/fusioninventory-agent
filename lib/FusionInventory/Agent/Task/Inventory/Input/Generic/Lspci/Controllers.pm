package FusionInventory::Agent::Task::Inventory::Input::Generic::Lspci::Controllers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

my $vendors;
my $classes;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $datadir   = $params{datadir};

    _loadPciIds(logger => $logger, datadir => $datadir);

    foreach my $controller (_getControllers(logger => $logger)) {
        $inventory->addEntry(
            section => 'CONTROLLERS',
            entry   => $controller
        );
    }
}

sub _getControllers {
    my @controllers;

    foreach my $device (getPCIDevices(@_)) {

        next unless $device->{PCIID};

        # duplicate entry to avoid modifying it directly
        my $controller = {
            PCICLASS     => $device->{PCICLASS},
            NAME         => $device->{NAME},
            MANUFACTURER => $device->{MANUFACTURER},
            REV          => $device->{REV},
            PCIID        => $device->{PCIID},
            PCISLOT      => $device->{PCISLOT},
        };
        $controller->{DRIVER} = $device->{DRIVER}
            if $device->{DRIVER};
        $controller->{PCISUBSYSTEMID} = $device->{PCISUBSYSTEMID}
            if $device->{PCISUBSYSTEMID};

        my ($vendor_id, $device_id) = split (/:/, $device->{PCIID});
        my $subdevice_id = $device->{PCISUBSYSTEMID};

        if ($vendors->{$vendor_id}) {
            my $vendor = $vendors->{$vendor_id};
            $controller->{MANUFACTURER} = $vendor->{name};

            if ($vendor->{devices}->{$device_id}) {
                my $entry = $vendor->{devices}->{$device_id};
                $controller->{CAPTION} = $entry->{name};

                $controller->{NAME} =
                    $subdevice_id && $entry->{subdevices}->{$subdevice_id} ?

                    $entry->{subdevices}->{$subdevice_id}->{name} :
                    $entry->{name};
            }
        }

        next unless $device->{PCICLASS};

        $device->{PCICLASS} =~ /^(\S\S)(\S\S)$/x;
        my $class_id = $1;
        my $subclass_id = $2;

        if ($classes->{$class_id}) {
            my $class = $classes->{$class_id};

            $controller->{TYPE} = 
                $subclass_id && $class->{subclasses}->{$subclass_id} ?
                    $class->{subclasses}->{$subclass_id}->{name} :
                    $class->{name};
        }

        push @controllers, $controller;
    }

    return @controllers;
}

sub _loadPciIds {
    my (%params) = @_;

    my $handle = getFileHandle(
        file   => "$params{datadir}/pci.ids",
        logger => $params{logger}
    );
    return unless $handle;

    my ($vendor_id, $device_id, $class_id);
    while (my $line = <$handle>) {

        if ($line =~ /^\t (\S{4}) \s+ (.*)/x) {
            # Device ID
            $device_id = $1;
            $vendors->{$vendor_id}->{devices}->{$device_id}->{name} = $2;
        } elsif ($line =~ /^\t\t (\S{4}) \s+ (\S{4}) \s+ (.*)/x) {
            # Subdevice ID
            my $subdevice_id = "$1:$2";
            $vendors->{$vendor_id}->{devices}->{$device_id}->{subdevices}->{$subdevice_id}->{name} = $3;
        } elsif ($line =~ /^(\S{4}) \s+ (.*)/x) {
            # Vendor ID
            $vendor_id = $1;
            $vendors->{$vendor_id}->{name} = $2;
        } elsif ($line =~ /^C \s+ (\S{2}) \s+ (.*)/x) {
            # Class ID
            $class_id = $1;
            $classes->{$class_id}->{name} = $2;
        } elsif ($line =~ /^\t (\S{2}) \s+ (.*)/x) {
            # SubClass ID
            my $subclass_id = $1;
            $classes->{$class_id}->{subclasses}->{$subclass_id}->{name} = $2;
        } 
    }
    close $handle;
}

1;
