package FusionInventory::Agent::Task::Inventory::OS::AIX::Sounds;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("lsdev");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $line (`lsdev -Cc adapter -F 'name:type:description'`) {
        next unless $line =~ /audio/i;
        next unless $line =~ /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/;
        $inventory->addSound({
            NAME         => $1,
            MANUFACTURER => $2,
            DESCRIPTION  => $3,
        });
    } 
}

1;
