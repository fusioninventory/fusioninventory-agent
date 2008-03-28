package Ocsinventory::Agent::Backend::OS::Solaris::Networks;


#ce5: flags=1000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4> mtu 1500 index 3
#        inet 55.37.101.171 netmask fffffc00 broadcast 55.37.103.255
#        ether 0:3:ba:24:9b:bf

use Net::IP qw(:PROC);;

use strict;

sub check {
  `ifconfig -a 2>&1`;
  return if ($? >> 8)!=0;

  `netstat 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

# Initialise the distro entry
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $description;
  my $ipaddress;
  my $ipgateway;
  my $ipmask;
  my $ipsubnet;
  my $macaddr;
  my $status;
  my $type;

  foreach (`netstat -rn`){
    $ipgateway=$1 if /^default\s+(\S+)/i;
  }

  foreach (`ifconfig -a`){
    $description = $1 if /^(\S+):/; # Interface name     
      $ipaddress = $1 if /inet\s+(\S+)/i;
    $ipmask = $1 if /\S*netmask\s+(\S+)/i;    
    if (/ether\s+(\S+)/i) {
# See
# https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
      $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
      map hex, split /\:/, $1;
    }
    $status = 1 if /<UP,/;      

    if(($description && $macaddr)){   
#HEX TO DEC TO BIN TO IP   	
      $ipmask = hex($ipmask);
      $ipmask = sprintf("%d", $ipmask);
      $ipmask = unpack("B*", pack("N", $ipmask));
      $ipmask = ip_bintoip($ipmask,4);     
#print $ipmask."\n";

      my $binip = &ip_iptobin ($ipaddress ,4);
      my $binmask = &ip_iptobin ($ipmask ,4);
      my $binsubnet = $binip & $binmask;
      $ipsubnet = ip_bintoip($binsubnet,4);     

      $inventory->addNetworks({  	   
	  DESCRIPTION => $description,
	  IPADDRESS => $ipaddress,	  
	  IPGATEWAY => $ipgateway,
	  IPMASK => $ipmask,
	  IPSUBNET => $ipsubnet,
	  MACADDR => $macaddr,
	  STATUS => $status?"Up":"Down",
	  TYPE => $type,
	  });

      $description = $macaddr = $status =  $type = undef;
    }
  }
}

1;
