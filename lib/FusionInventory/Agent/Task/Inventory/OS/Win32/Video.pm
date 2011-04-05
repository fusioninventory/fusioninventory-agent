package FusionInventory::Agent::Task::Inventory::OS::Win32::Video;

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
        class      => 'Win32_VideoController',
        properties => [ qw/
            CurrentHorizontalResolution CurrentVerticalResolution VideoProcessor
            AdaptaterRAM Name
        / ]
    )) {

        my $resolution;
        if ($object->{CurrentHorizontalResolution}) {
            $resolution =
                $object->{CurrentHorizontalResolution} .
                "x" .
                $object->{CurrentVerticalResolution};
        }

        my $memory;
        if ($object->{AdaptaterRAM}) {
            $memory = int($object->{AdaptaterRAM} / (1024*1024));
        }

        $inventory->addVideo({
            CHIPSET    => $object->{VideoProcessor},
            MEMORY     => $memory,
            NAME       => $object->{Name},
            RESOLUTION => $resolution
        });
    }
}

1;
