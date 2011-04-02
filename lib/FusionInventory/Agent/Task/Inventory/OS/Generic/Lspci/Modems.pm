package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach(`lspci`){

        if(/modem/i && /\d+\s(.+):\s*(.+)$/){
            my $name = $1;
            my $description = $2;
            $inventory->addModem({
                'DESCRIPTION'  => $description,
                'NAME'          => $name,
            });
        }
    }
}

1;
