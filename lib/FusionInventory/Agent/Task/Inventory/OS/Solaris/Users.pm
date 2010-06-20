package FusionInventory::Agent::Task::Inventory::OS::Solaris::Users;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run ("who");
} 

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %user;
# Logged on users
    for(`who`){
        $user{$1} = 1 if /^(\S+)./;
    }

    my $UsersLoggedIn = join "/", keys %user;

    $inventory->setHardware ({ USERID => $UsersLoggedIn });
}

1;
