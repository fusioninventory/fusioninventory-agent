package FusionInventory::Agent::Task::Inventory::OS::Linux::Mem;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { can_read ("/proc/meminfo") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $unit = 1024;

    my $PhysicalMemory;
    my $SwapFileSize;

    # Memory informations
    if (open my $handle, '<', '/proc/meminfo') {
        while(<$handle>){
            $PhysicalMemory=$1 if /^memtotal\s*:\s*(\S+)/i;
            $SwapFileSize=$1 if /^swaptotal\s*:\s*(\S+)/i;
        }
        close $handle;
    } else {
        warn "Can't open /proc/meminfo: $ERRNO";
    }

    # TODO
    $inventory->setHardware({
        MEMORY =>  sprintf("%i",$PhysicalMemory/$unit),
        SWAP =>    sprintf("%i", $SwapFileSize/$unit),
    });
}

1;
