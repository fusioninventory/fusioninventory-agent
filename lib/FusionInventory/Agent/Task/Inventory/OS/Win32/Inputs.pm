package FusionInventory::Agent::Task::Inventory::OS::Win32::Inputs;

use strict;
use warnings;

# Had never been tested.
use FusionInventory::Agent::Tools::Win32;

my %mouseInterface = (
    1 =>  'Other',
    2 => 'Unknown',
    3 => 'Serial',
    4 => 'PS/2',
    5 => 'Infrared',
    6 => 'HP-HIL',
    7 => 'Bus Mouse',
    8 => 'ADB (Apple Desktop Bus)',
    160 => 'Bus Mouse DB-9',
    161 => 'Bus Mouse Micro-DIN',
    162 => 'USB',
);

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $logger    = $params{logger};
    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_Keyboard',
        properties => [ qw/Name Caption Manufacturer Description Layout/ ]
    )) {

        $inventory->addEntry(
            section => 'INPUTS',
            entry   => {
                NAME         => $object->{Name},
                CAPTION      => $object->{Caption},
                MANUFACTURER => $object->{Manufacturer},
                DESCRIPTION  => $object->{Description},
                LAYOUT       => $object->{Layout},
            }
        );
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_PointingDevice',
        properties => [ qw/Name Caption Manufacturer Description PointingType DeviceInterface/ ]
    )) {

        $inventory->addEntry(
            section => 'INPUTS',
            entry   => {
                NAME         => $object->{Name},
                CAPTION      => $object->{Caption},
                MANUFACTURER => $object->{Manufacturer},
                DESCRIPTION  => $object->{Description},
                POINTINGTYPE => $object->{PointingType},
                INTERFACE    => $mouseInterface{$object->{DeviceInterface}},
            }
        );
    }

}

1;
