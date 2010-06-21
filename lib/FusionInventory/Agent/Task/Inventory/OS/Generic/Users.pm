package FusionInventory::Agent::Task::Inventory::OS::Generic::Users;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run('who');
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %user;
    # Logged on users
    for(`who`){
        my $user;
        $user = $1 if /^(\S+)./;
        $inventory->addUser ({ LOGIN => $user });
    }

}

1;
