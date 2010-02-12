package FusionInventory::Agent::Task::Inventory::OS::Generic::Users;

sub isInventoryEnabled {
# Useless check for a posix system i guess
  my @who = `who 2>/dev/null`;
  return 1 if @who;
  return;
}

# Initialise the distro entry
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my %user;
  # Logged on users
  for(`who`){
    my $user = $1 if /^(\S+)./;
    $inventory->addUser ({ LOGIN => $user });
  }

}

1;
