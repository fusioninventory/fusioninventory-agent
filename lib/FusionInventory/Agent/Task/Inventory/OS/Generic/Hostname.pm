package FusionInventory::Agent::Task::Inventory::OS::Generic::Hostname;

use strict;
use warnings;

use Sys::Hostname;

sub isInventoryEnabled {
    return 1;
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $hostname = hostname();

    $hostname =~ s/\..*//; # keep just the hostname

    $inventory->setHardware ({NAME => $hostname});
}

1;
