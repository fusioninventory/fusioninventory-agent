package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC::Various;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { 1 };

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    ############ Motherboard
    my $SystemManufacturer;
    my $SystemModel;
    my $SystemSerial;
    my $BiosManufacturer;
    my $BiosVersion;
    my $BiosDate;

    if (open my $handle, '<', '/proc/device-tree/serial-number') {
        $SystemSerial = <$handle>;
        $SystemSerial =~ s/[^\,^\.^\w^\ ]//g; # I remove some unprintable char
        close $handle;
    } else {
        warn "Can't open /proc/device-tree/serial-number: $ERRNO";
    }

    if (open my $handle, '<', '/proc/device-tree/model') {
        $SystemModel = <$handle>;
        $SystemModel =~ s/[^\,^\.^\w^\ ]//g;
        close $handle;
    } else {
        warn "Can't open /proc/device-tree/model: $ERRNO";
    }

    if (open my $handle, '<', '/proc/device-tree/color-code') {
        my $tmp = <$handle>;
        close $handle;
        my ($color) = unpack "h7" , $tmp;
        $SystemModel = $SystemModel." color: $color" if $color;
    } else {
        warn "Can't open /proc/device-tree/color-code: $ERRNO";
    }

    if (open my $handle, '<', '/proc/device-tree/openprom/model') {
        $BiosVersion = <$handle>;
        $BiosVersion =~ s/[^\,^\.^\w^\ ]//g;
        close $handle;
    } else {
        warn "Can't open /proc/device-tree/openprom/model: $ERRNO";
    }

    if (open my $handle, '<', '/proc/device-tree/copyright') {
        my $tmp = <$handle>;
        close $handle;

        if ($tmp =~ /Apple/) {
            # What about the Apple clone?
            $BiosManufacturer = "Apple Computer, Inc.";
            $SystemManufacturer = "Apple Computer, Inc." 
        }
    } else {
        warn "Can't open /proc/device-tree/copyright: $ERRNO";
    }

    $inventory->setBios ({
        SMANUFACTURER => $SystemManufacturer,
        SMODEL => $SystemModel,
        SSN => $SystemSerial,
        BMANUFACTURER => $BiosManufacturer,
        BVERSION => $BiosVersion,
        BDATE => $BiosDate,
    });

}

1;
