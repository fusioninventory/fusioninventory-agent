package Ocsinventory::Agent::Backend::OS::Generic::Hostname;

sub check {
  eval { require (Sys::Hostname) };
  return 1 unless $@;
  `which hostname 2>&1`;
  return if ($? >> 8)!=0;
  `hostname 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  #chomp ( my $hostname = `hostname` );
  eval { require (Sys::Hostname) };
  if (!$@) {
    $hostname = Sys::Hostname::hostname();
  } else {
    chomp ( $hostname = `hostname` ); # TODO: This is not generic.
  }
  $hostname =~ s/\..*//; # keep just the hostname


  $inventory->setHardware ({NAME => $hostname});
}

1;
