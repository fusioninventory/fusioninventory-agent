package FusionInventory::Agent::Task::Inventory::OS::Generic::Hostname;

use English qw(-no_match_vars);

use strict;
use warnings;

use Sys::Hostname;

sub isInventoryEnabled {
# We use WMI for Windows because of charset issue
    return $OSNAME ne 'MSWin32';
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
