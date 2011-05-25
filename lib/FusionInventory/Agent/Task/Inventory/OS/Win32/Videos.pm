package FusionInventory::Agent::Task::Inventory::OS::Win32::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

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

        $object->{AdaptaterRAM} = int($object->{AdaptaterRAM} / (1024 * 1024))
            if $object->{AdaptaterRAM};

        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => {
                CHIPSET    => $object->{VideoProcessor},
                MEMORY     => $object->{AdaptaterRAM},
                NAME       => $object->{Name},
                RESOLUTION => $resolution
            },
            noDuplicated => 1
        );
    }
}

1;
