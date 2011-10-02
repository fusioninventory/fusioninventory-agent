package FusionInventory::Agent::Task::Inventory::Input::Win32::USB;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

my $seen;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'CIM_LogicalDevice',
        properties => [ qw/DeviceID Name/ ]
    )) {
        next unless $object->{DeviceID} =~ /^USB\\VID_(\w+)&PID_(\w+)(.*)/;

        my $device = {
            NAME      => $object->{Name},
            VENDORID  => $1,
            PRODUCTID => $2,
            SERIAL    => $3
        };

        $device->{SERIAL} =~ s/.*?&//;
        $device->{SERIAL} =~ s/&.*$//;

        next if $device->{VENDORID} =~ /^0+$/;

        # avoid duplicates
        next if $seen->{$device->{SERIAL}}++;

        $inventory->addEntry(
            section => 'USBDEVICES',
            entry   => $device
        );
    }
}

1;
