package Ocsinventory::Agent::Backend::OS::BSD::Networks;

use Net::IP qw(:PROC);;

use strict;

sub check {
  my @ifconfig = `ifconfig -a 2>/dev/null`;
  return @ifconfig?1:0;
}


sub _ipdhcp {
  my $if = shift;

  my $path;
  my $dhcp;
  my $ipdhcp;
  my $leasepath;


  foreach ( # XXX BSD paths
    "/var/db/dhclient.leases.%s",
    "/var/db/dhclient.leases" ) {

    $leasepath = sprintf($_,$if);
    last if (-e $leasepath);
   }
  return unless $leasepath;

  if (open DHCP, $leasepath) {
    my $lease;
    while(<DHCP>){
      $lease = 1 if(/lease\s*{/i);
      $lease = 0 if(/^\s*}\s*$/);
#Interface name
      if ($lease) { #inside a lease section
	if(/interface\s+"(.+?)"\s*/){
	  $dhcp = ($1 =~ /^$if$/);
}
#Server IP
	if(/option\s+dhcp-server-identifier\s+(\d{1,3}(?:\.\d{1,3}){3})\s*;/ and $dhcp){
	  $ipdhcp = $1;
}
}
}
    close DHCP or warn;
} else {
    warn "Can't open $leasepath\n";
}
  return $ipdhcp;
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

  
  # Looking for the gateway
  # 'route show' doesn't work on FreeBSD so we use netstat
  for(`netstat -nr`){
    $ipgateway=$1 if /^default\s+(\S+)/i;
  }

  my @ifconfig = `ifconfig -a`; # -a option required on *BSD


  # first make the list available interfaces
  # too bad there's no -l option on OpenBSD
  my @list;
  foreach (@ifconfig){
      # skip loopback, pseudo-devices and point-to-point interfaces
      next if /^(lo|vmnet|sit|pflog|pfsync|enc|plip|sl|ppp)\d+/;
      if (/^(\S+):/) { push @list , $1; } # new interface name	  
  }

  # for each interface get it's parameters
  foreach $description (@list) {
      $ipaddress = $ipmask = $macaddr = $status =  $type = undef;
      my $flag = 0;
      foreach (@ifconfig){ # search interface infos
	  last if (/^(\S+):/ && $flag);
	  if (/^$description/) { $flag = 1; }
	  if ($flag) {
	      $ipaddress = $1 if /inet (\S+)/i;
	      $ipmask = $1 if /netmask\s+(\S+)/i;
	      $macaddr = $2 if /(address:|ether)\s+(\S+)/i;
	      $status = 1 if /<UP/i;
	      $type = $1 if /media:\s+(\S+)/i;
	  }
      }
      my $binip = &ip_iptobin ($ipaddress ,4);
      # In BSD, netmask is given in hex form
      my $binmask = sprintf("%b", oct($ipmask));
      my $binsubnet = $binip & $binmask;
      $ipsubnet = ip_bintoip($binsubnet,4);
      
      $inventory->addNetworks({
	  
	  DESCRIPTION => $description,
	  IPADDRESS => $ipaddress,
	  IPDHCP => _ipdhcp($description),
	  IPGATEWAY => $ipgateway,
	  IPMASK => $ipmask,
	  IPSUBNET => $ipsubnet,
	  MACADDR => $macaddr,
	  STATUS => $status?"Up":"Down",
	  TYPE => $type,
	  
      });
  }
}

1;
