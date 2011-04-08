package FusionInventory::Agent::Task::Inventory::OS::Win32::Modem;

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
        class      => 'Win32_POTSModem',
        properties => [ qw/Name DeviceType Model Description/ ]
    )) {

        $inventory->addEntry({
            section => 'MODEMS',
            entry   => {
                NAME        => $object->{Name},
                TYPE        => $object->{DeviceType},
                MODEL       => $object->{Model},
                DESCRIPTION => $object->{Description},
            }
        });
    }
}

1;
