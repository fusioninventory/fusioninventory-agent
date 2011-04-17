package FusionInventory::Agent::Task::Inventory::OS::AIX::Mem;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run("lsdev") ||
        can_run("which") ||
        can_run("lsattr");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $memory;
    my $swap;

    #Memory informations
    #lsdev -Cc memory -F 'name' -t totmem
    #lsattr -EOlmem0
    my (@lsdev, @lsattr, @grep);
    $memory=0;
    @lsdev=`lsdev -Cc memory -F 'name' -t totmem`;
    foreach (@lsdev){
        @lsattr=`lsattr -EOl$_`;
        foreach (@lsattr){
            if (! /^#/){
                # See: http://forge.fusioninventory.org/issues/399
                # TODO: the regex should be improved here
                /^(.+):(\d+)/;
                $memory += $2;
            }
        }
    }

    #Paging Space
    @grep=`lsps -s`;
    foreach (@grep){
        if ( ! /^Total/){
            /^\s*(\d+)\w*\s+\d+.+/;
            $swap=$1;
        }
    }

    $inventory->setHardware({
        MEMORY => $memory,
        SWAP => $swap 
    });

}

1;
