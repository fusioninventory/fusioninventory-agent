package FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $line (`lsdev -Cc adapter -F 'name:type:description'`) {
        next unless $line =~ /graphics|vga|video/i;
        next unless $line =~ /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/;
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => {
                CHIPSET => $1,
                NAME    => $2,
            },
            noDuplicated => 1
        );
    }
}

1;
