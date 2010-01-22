package Ocsinventory::Agent::Backend::OS::HPUX::IPv4;

sub check {`which ifconfig 2>&1`; ($? >> 8)?0:1 
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  my @ip;

  $ip=`grep n4004rec /etc/hosts | head -1 | cut -f 1`;
  $inventory->setHardware({IPADDR => $ip});
}

1;
