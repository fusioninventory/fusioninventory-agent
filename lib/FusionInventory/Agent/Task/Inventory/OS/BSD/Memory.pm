package FusionInventory::Agent::Task::Inventory::OS::BSD::Memory;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 	
    return
        can_run('sysctl') &&
        can_run('swapctl');
};

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Swap
    my $SwapFileSize;
    my @bsd_swapctl = `swapctl -sk`;
    foreach (@bsd_swapctl) {
        $SwapFileSize = $1 if /total:\s*(\d+)/i;
    }

    # RAM
    my $PhysicalMemory = getFirstLine(command => 'sysctl -n hw.physmem');
    $PhysicalMemory = $PhysicalMemory / 1024;

    $inventory->setHardware(
        MEMORY => sprintf("%i", $PhysicalMemory / 1024),
        SWAP   => sprintf("%i", $SwapFileSize / 1024),
    );
}

1;
