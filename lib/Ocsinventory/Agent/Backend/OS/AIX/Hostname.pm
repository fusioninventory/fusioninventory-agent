package Ocsinventory::Agent::Backend::OS::AIX::Hostname;

sub check { `which hostname`; ($? >> 8)?0:1}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  chomp ( my $hostname = `hostname` );

  $inventory->setHardware ({NAME => $hostname});
}

1;
