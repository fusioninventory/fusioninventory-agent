package FusionInventory::Agent::Task::Inventory::OS::AIX::IPv4;

sub isInventoryEnabled {`which ifconfig 2>&1`; ($? >> 8)?0:1 
}

# Initialise the distro entry
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $ip;
  my $hostname;

  if ( `hostname` =~ /(\S+)/ )
  {
      $hostname=$1;
  }

  for ( `grep $hostname /etc/hosts ` )
  {
     if ( /(^\d+\.\d+\.\d+\.\d+)\s+/ )
     {
        $ip=$1;
        $inventory->setHardware({IPADDR => $ip});
     }
  }
}

1;
