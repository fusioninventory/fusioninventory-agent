package FusionInventory::Agent::Task::Inventory::OS::Win32::USB;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

my @devices;

sub alreadyIn {
    my ($vendorId, $productId, $serial) = @_;

    foreach (@devices) {
        if (
            ($_->{vendorId} eq $vendorId)
              &&
            ($_->{productId} eq $productId)
              &&
            ($_->{serial} eq $serial)
            ) {
            return 1;
        }
    }

    push @devices, {
        vendorId => $vendorId,
        productId => $productId,
        serial => $serial
    };

    return;
}

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};

    foreach my $wmiClass (qw/CIM_LogicalDevice/) {
        foreach my $Properties (getWmiProperties($wmiClass, qw/DeviceID Name/)) {
            next unless $Properties->{DeviceID} =~ /^USB\\VID_(\w+)&PID_(\w+)(\\|$)(.*)/;

            my $vendorId = $1;
            my $productId = $2;
            my $serial = $4;

            $serial =~ s/.*?&//;
            $serial =~ s/&.*$//;

            next if $vendorId =~ /^0+$/;

            next if alreadyIn($vendorId, $productId, $serial);

            $inventory->addUSBDevice({
                NAME => $Properties->{Name},
                VENDORID => $vendorId,
                PRODUCTID => $productId,
                SERIAL => $serial
            });
        }
    }
}
1;
