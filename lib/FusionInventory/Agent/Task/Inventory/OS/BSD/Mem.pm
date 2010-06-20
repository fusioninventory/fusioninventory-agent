package FusionInventory::Agent::Task::Inventory::OS::BSD::Mem;

use strict;
use warnings;

sub isInventoryEnabled { 	
    `which sysctl 2>&1`;
    return 0 if($? >> 8);
    `which swapctl 2>&1`;
    return 0 if($? >> 8);
    1;
};

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $PhysicalMemory;
    my $SwapFileSize;

# Swap
    my @bsd_swapctl= `swapctl -sk`;
    for(@bsd_swapctl){
        $SwapFileSize=$1 if /total:\s*(\d+)/i;
    }
# RAM
    chomp($PhysicalMemory=`sysctl -n hw.physmem`);
    $PhysicalMemory=$PhysicalMemory/1024;

# Send it to inventory object
    $inventory->setHardware({
        MEMORY =>  sprintf("%i",$PhysicalMemory/1024),
        SWAP =>    sprintf("%i", $SwapFileSize/1024),
    });
}
1;
