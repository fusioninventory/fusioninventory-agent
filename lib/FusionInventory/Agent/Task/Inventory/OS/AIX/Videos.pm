package FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("lsdev");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    for(`lsdev -Cc adapter -F 'name:type:description'`){
        if(/graphics|vga|video/i){
            if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
                $inventory->addVideo({
                    'CHIPSET'  => $1,
                    'NAME'     => $2,
                });
            }
        }
    }
}

1;
