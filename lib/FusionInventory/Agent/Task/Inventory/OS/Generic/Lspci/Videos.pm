package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach(`lspci`) {
        if (/graphics|vga|video/i) {
            next unless /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i;

            $inventory->addVideo({
                'CHIPSET' => $1,
                'NAME'    => $2,
            });
        }
    }
}

1;
