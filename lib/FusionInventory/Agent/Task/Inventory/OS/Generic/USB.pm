package FusionInventory::Agent::Task::Inventory::OS::Generic::USB;
# tested with:
# lsusb (usbutils) 0.86

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("lsusb");
}

sub addDevice {
    my ($inventory, $device) = @_;

    my $class = $device->{class};
    my $subClass = $device->{subClass};
    my $productId = $device->{productId};
    my $vendorId = $device->{vendorId};
    my $serial;


    return unless $productId;
    return unless $vendorId;

    # We ignore the USB Hub
    return if $productId eq "0001";
    return if $productId eq "0002";

    if (defined($device->{serial}) && length($device->{serial}) > 4) {
        $serial =  $device->{serial};
    }
    $inventory->addUSBDevice({

            VENDORID => $vendorId,
            PRODUCTID => $productId,
            SERIAL => $serial,
            CLASS => $class,
            SUBCLASS => $subClass,

        });

}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $in;
    my $device;
    foreach (`lsusb -v`) {
        if (/^Device/) {
            $in = 1;
        } elsif (/^\s*$/) {
            $in =0;
            addDevice($inventory, $device);
            $device = {};
        } elsif ($in) {
            if (/^\s*idVendor\s*0x(\w+)/i) {
                $device->{vendorId}=$1;
            }
            if (/^\s*idProduct\s*0x(\w+)/i) {
                $device->{productId}=$1;
            }
            if (/^\s*iSerial\s*\d+\s(\w+)/i) {
                $device->{serial}=$1;
            }
            if (/^\s*bInterfaceClass\s*(\d+)/i) {
                $device->{class}=$1;
            }
            if (/^\s*bInterfaceSubClass\s*(\d+)/i) {
                $device->{subClass}=$1;
            }
        }
    }
    addDevice($device);
}

1;
