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
    my $logger    = $params{logger};

    my ($memory) = getFirstMatch(
        command => 'prtconf',
        logger  => $logger,
        pattern => qr/^Memory\ssize:\s+(\S+)/
    );

    my ($swap) = getFirstMatch(
        command => 'swap -l',
        logger  => $logger,
        pattern => qr/\s+(\S+)$/
    );

    $inventory->setHardware(
        MEMORY => $memory,
        SWAP =>   $swap
    );
}

1
