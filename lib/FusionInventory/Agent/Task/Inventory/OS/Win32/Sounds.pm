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

            NAME => encode('UTF-8', $Properties->{Name}),
            CAPTION => encode('UTF-8', $Properties->{Caption}),
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            DESCRIPTION => encode('UTF-8', $Properties->{Description}),

        });

    }
}
1;
