package Ocsinventory::Agent::Backend::OS::Solaris::Users;

sub check { can_run ("who") } 

# Initialise the distro entry
sub run {
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
