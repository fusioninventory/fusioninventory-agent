package FusionInventory::Agent::Task::Inventory::OS::AIX::Sounds;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach (`lsdev -Cc adapter -F 'name:type:description'`){
        if(/audio/i){
            if(/^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i){
                $inventory->addSound({
                    'DESCRIPTION'  => $3,
                    'MANUFACTURER' => $2,
                    'NAME'     => $1,
                });
            }
        }
    } 
}

1;
