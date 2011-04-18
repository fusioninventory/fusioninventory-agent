package FusionInventory::Agent::Task::Inventory::OS::AIX::Modems;

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
        next unless $line =~ /modem/i;
        next unless $line =~ /\d+\s(.+):(.+)$/;
        $inventory->addEntry(
            section => 'MODEMS',
            entry   => {
                NAME        => $1,
                DESCRIPTION => $2
            }
        );
    }
}

1;
