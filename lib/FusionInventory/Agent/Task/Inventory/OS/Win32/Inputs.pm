package FusionInventory::Agent::Task::Inventory::OS::Win32::Inputs;

use strict;
use warnings;

# Had never been tested.
use FusionInventory::Agent::Task::Inventory::OS::Win32;

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

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my @inputs;
    foreach my $Properties (getWmiProperties(
            'Win32_Keyboard', qw/Name Caption Manufacturer Description Layout/)
    ) {

        push @inputs, {

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            MANUFACTURER => $Properties->{Manufacturer},
            DESCRIPTION => $Properties->{Description},
            LAYOUT => $Properties->{Layout},

        };

    }

        foreach my $Properties
            (getWmiProperties('Win32_PointingDevice',
qw/Name Caption Manufacturer Description PointingType DeviceInterface/))
    {

        push @inputs, {

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            MANUFACTURER => $Properties->{Manufacturer},
            DESCRIPTION => $Properties->{Description},
            POINTINGTYPE => $Properties->{PointingType},
            INTERFACE => $mouseInterface{$Properties->{DeviceInterface}},

        };

    }


    foreach (@inputs) {
        $inventory->addInput($_);
    }

}
1;
