package FusionInventory::Agent::Task::Inventory::OS::Generic::Environement;

use strict;
use warnings;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach my $key (keys %ENV) {
        $inventory->addEnv({
            KEY => $key,
            VAL => $ENV{$key}
        });
    }
}

1;
