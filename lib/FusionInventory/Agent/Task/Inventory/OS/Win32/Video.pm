package FusionInventory::Agent::Task::Inventory::OS::Win32::Video;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


        foreach my $Properties
            (getWmiProperties('Win32_VideoController',
qw/CurrentHorizontalResolution CurrentVerticalResolution VideoProcessor
AdaptaterRAM Name/)) {

        my $resolution;
        if ($Properties->{CurrentHorizontalResolution}) {
            $resolution = $Properties->{CurrentHorizontalResolution} ."x".$Properties->{CurrentVerticalResolution};
        }

        $inventory->addVideo({
                CHIPSET => $Properties->{VideoProcessor},
                MEMORY =>  int($Properties->{AdaptaterRAM} / (1024*1024)),
                NAME => $Properties->{Name},
                RESOLUTION => $resolution
                });

    }




}

1;
