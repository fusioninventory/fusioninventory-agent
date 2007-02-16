package Ocsinventory::Agent::Backend::OS::AIX::IPv4;

sub check {`which ifconfig 2>&1`; ($? >> 8)?0:1 
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  my @ip;

  #Looking for ip addresses with ifconfig, except loopback
  # AIX need -a option
  for(`ifconfig -a`){#ifconfig in the path
    # AIX ligne inet
    if(/^\s*inet\s+(\S+).*/){($1=~/127.+/)?next:push @ip, $1};
  }
  $ip=join "/", @ip;
  $inventory->setHardware({IPADDR => $ip});
}

1;
