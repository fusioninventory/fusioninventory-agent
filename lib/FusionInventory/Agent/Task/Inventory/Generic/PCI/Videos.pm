package FusionInventory::Agent::Task::Inventory::Generic::PCI::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{video};
    # both windows and linux have dedicated modules
    return
        $OSNAME ne 'MSWin32' &&
        $OSNAME ne 'linux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $video (_getVideos(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video
        );
    }
}

sub _getVideos {
    my @videos;

    foreach my $device (getPCIDevices(@_)) {
        next unless $device->{NAME} =~ /graphics|vga|video|display/i;
        push @videos, {
            CHIPSET => $device->{NAME},
            NAME    => $device->{MANUFACTURER},
        };
    }

    return @videos;
}

1;
