package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Sounds;

use strict;
use warnings;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach(`lspci`){
        if(/audio/i && /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
            $inventory->addSound({
                NAME         => $1,
                MANUFACTURER => $2,
                DESCRIPTION  => $3
            });
        }
    }
}

1;
