package FusionInventory::Agent::Task::Inventory::OS::Win32::Sounds;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use strict;

sub isInventoryEnabled {1}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};


    foreach my $Properties
        (getWmiProperties('Win32_SoundDevice',
qw/Name Manufacturer Caption Description/)) {

        $inventory->addSound({

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            MANUFACTURER => $Properties->{Manufacturer},
            DESCRIPTION => $Properties->{Description},

        });

    }
}
1;
