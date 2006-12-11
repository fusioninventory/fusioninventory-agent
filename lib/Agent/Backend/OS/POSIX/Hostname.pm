package Ocsinventory::Agent::Backend::OS::POSIX::Hostname;

sub check {1} # No check yet

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  chomp ( my $hostname = `hostname` );

  # TODO $h->{'CONTENT'}{'HARDWARE'}{'NAME'} = [$hostname];

}

1;
