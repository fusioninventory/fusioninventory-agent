package FusionInventory::Agent::Task::Inventory::OS::Linux::Mem;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return -r '/proc/meminfo';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(file => '/proc/meminfo', logger => $logger);
    return unless $handle;

    my $unit = 1024;
    my $PhysicalMemory;
    my $SwapFileSize;

    while (my $line = <$handle>) {
        $PhysicalMemory=$1 if /^memtotal\s*:\s*(\S+)/i;
        $SwapFileSize=$1 if /^swaptotal\s*:\s*(\S+)/i;
    }
    close $handle;

    $inventory->setHardware(
        MEMORY => sprintf("%i", $PhysicalMemory/$unit),
        SWAP   => sprintf("%i", $SwapFileSize/$unit),
    );
}

1;
