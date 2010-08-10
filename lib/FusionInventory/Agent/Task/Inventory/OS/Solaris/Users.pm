package FusionInventory::Agent::Task::Inventory::OS::Solaris::Users;

sub isInventoryEnabled { can_run ("who") }

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %user;
# Logged on users
    for(`who`){
        $inventory->addUser($1) if /^(\S+)./;
    }

}

1;
