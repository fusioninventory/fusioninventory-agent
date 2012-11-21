package FusionInventory::Agent::Task::Inventory::Input::Generic::USB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return canRun('lsusb');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $device (_getDevices(logger => $params{logger})) {
        next unless $device->{PRODUCTID};
        next unless $device->{VENDORID};

        # ignore the USB Hub
        next if
            $device->{PRODUCTID} eq "0001" ||
            $device->{PRODUCTID} eq "0002" ;

        if (defined($device->{SERIAL}) && length($device->{SERIAL}) < 5) {
            $device->{SERIAL} = undef;
        }

        my $vendor = getUSBDeviceVendor(
            id => $device->{VENDORID}, datadir => $params{datadir}
        );
        if ($vendor) {
            $device->{MANUFACTURER} = $vendor->{name};

            my $entry = $vendor->{devices}->{$device->{PRODUCTID}};
            if ($entry) {
                $device->{CAPTION} = $entry->{name};
            }
        }

        $inventory->addEntry(
            section => 'USBDEVICES',
            entry   => $device,
        );
    }
}

sub _getDevices {
    my $handle = getFileHandle(
        @_,
        command => 'lsusb -v',
    );

    return unless $handle;

    my @devices;
    my $device;

    while (my $line = <$handle>) {
        if ($line =~ /^$/) {
            push @devices, $device if $device;
            undef $device;
        } elsif ($line =~ /^\s*idVendor\s*0x(\w+)/i) {
            $device->{VENDORID} = $1;
        } elsif ($line =~ /^\s*idProduct\s*0x(\w+)/i) {
            $device->{PRODUCTID} = $1;
        } elsif ($line =~ /^\s*iSerial\s*\d+\s(\w+)/i) {
            $device->{SERIAL} = $1;
        } elsif ($line =~ /^\s*bInterfaceClass\s*(\d+)/i) {
            $device->{CLASS} = $1;
        } elsif ($line =~ /^\s*bInterfaceSubClass\s*(\d+)/i) {
            $device->{SUBCLASS} = $1;
        }
    }
    close $handle;
    push @devices, $device if $device;

    return @devices;
}

1;
