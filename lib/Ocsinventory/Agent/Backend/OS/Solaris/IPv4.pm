package Ocsinventory::Agent::Backend::OS::Solaris::IPv4;

sub check {
  `ifconfig -a 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  my @ip;

#Looking for ip addresses with ifconfig, except loopback
# Solaris need -a option
  for(`ifconfig -a`){#ifconfig in the path
#Solarisligne inet
    if(/^\s*inet\s+(\S+).*/){($1=~/127.+/)?next:push @ip, $1};
  }
  $ip=join "/", @ip;
  $inventory->setHardware({IPADDR => $ip});
}

1;
