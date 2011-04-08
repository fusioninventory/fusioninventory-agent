package FusionInventory::Agent::Task::Inventory::OS::Win32::USB;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $object (getWmiObjects(
        class      => 'CIM_LogicalDevice',
        properties => [ qw/DeviceID Name/ ]
    )) {
        next unless $object->{DeviceID} =~ /^USB\\VID_(\w+)&PID_(\w+)(\\|$)(.*)/;

        my $vendorId = $1;
        my $productId = $2;
        my $serial = $4;

        $serial =~ s/.*?&//;
        $serial =~ s/&.*$//;

        next if $vendorId =~ /^0+$/;

        $inventory->addEntry({
            section => 'USBDEVICES',
            entry   => {
                NAME      => $object->{Name},
                VENDORID  => $vendorId,
                PRODUCTID => $productId,
                SERIAL    => $serial
            },
            noDuplicated => 1
        });
    }
}

1;
