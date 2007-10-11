package Ocsinventory::Agent::Backend::OS::Linux::Network::Networks;

use Net::IP qw(:PROC);;

use strict;

sub check {
  my @ifconfig = `ifconfig 2>/dev/null`;
  return unless @ifconfig;
  my @route = `route -n 2>/dev/null`;
  return unless @route;

  1;
}


sub _ipdhcp {
  my $if = shift;

  my $path;
  my $dhcp;
  my $ipdhcp;
  my $leasepath;

  foreach (
    "/var/lib/dhcp3/dhclient.%s.leases",
    "/var/lib/dhcp3/dhclient.%s.leases",
    "/var/lib/dhcp/dhclient.leases", ) {

    $leasepath = sprintf($_,$if);
    last if (-e $leasepath);
  }
  return undef unless -e $leasepath;

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


  my %gateway;
  
  foreach (`route -n`) {
    if (/^(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/) {
      $gateway{$1} = $2;
    }
  }

  foreach (`ifconfig -a`) {
    if (/^$/ && $description !~ /^(lo|vmnet\d+|sit\d+)$/) {
      # end of interface section 
      # I write the entry
      my $binip = &ip_iptobin ($ipaddress ,4);
      my $binmask = &ip_iptobin ($ipmask ,4);
      my $binsubnet = $binip & $binmask;
      $ipsubnet = ip_bintoip($binsubnet,4);

      my @wifistatus = `iwconfig $description 2>>/dev/null`;
      if ( @wifistatus > 2 ) {
	$type = "Wifi";
      }

      $ipgateway = $gateway{$ipsubnet}; 

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

      $description =  $ipgateway = $macaddr = $status =  $type = undef;
    }

      $description = $1 if /^(\S+)/; # Interface name
      $ipaddress = $1 if /inet addr:(\S+)/i;
      $ipmask = $1 if /\S*mask:(\S+)/i;
      $macaddr = $1 if /hwadd?r\s+(\S+)/i;
      $status = 1 if /^\s+UP\s/;
      $type = $1 if /link encap:(\S+)/i;


  }
}

1;
