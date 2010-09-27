package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging;

use strict;
use warnings;

sub isInventoryEnabled {
    my $params = shift;

    return 
        $params->{config}->{'no-software'} ? 0 : 1;
}

sub doInventory { }

1;
