package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging;

use strict;
use warnings;

sub isInventoryEnabled {
    my $params = shift;

    # Do not run an package inventory if there is the --nosoft parameter
    return 
        $params->{config}->{'no-software'} ? 0 : 1;
}

1;
