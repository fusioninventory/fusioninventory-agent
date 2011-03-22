package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return 0 if $OSNAME eq 'MSWin32';
    return 0 if $OSNAME eq 'linux';
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach(`lspci`) {
        if (/graphics|vga|video/i) {
            next unless /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i;

            $inventory->addVideo({
                'CHIPSET' => $1,
                'NAME'    => $2,
            });
        }
    }
}

1;
