package Ocsinventory::Agent::Backend::OS::Generic::Hostname;

sub check {1} # No check yet

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  chomp ( my $hostname = `hostname` );

  $inventory->setHardware ({NAME => $hostname});
}

1;
