package FusionInventory::Agent::Task::Inventory::OS::Win32::Modem;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    foreach my $Properties (getWmiProperties('Win32_POTSModem', qw/
        Name DeviceType Model Description
    /)) {

        $inventory->addModem({
            NAME => $Properties->{Name},
            TYPE => $Properties->{DeviceType},
            MODEL => $Properties->{Model},
            DESCRIPTION => $Properties->{Description},
        });
    }
}

1;
