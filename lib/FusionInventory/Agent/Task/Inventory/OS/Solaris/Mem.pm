package FusionInventory::Agent::Task::Inventory::OS::Solaris::Mem;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        can_run('swap') &&
        can_run('prtconf');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $memory;
    foreach (`prtconf`) {
        next unless /^Memory\ssize:\s+(\S+)/;
        $memory = $1;
    }

    my $swap;
    foreach (`swap -l`) {
        next unless /\s+(\S+)$/;
        $swap = $1;
    }

    $inventory->setHardware(
        MEMORY => $memory,
        SWAP =>   $swap
    );
}

1
