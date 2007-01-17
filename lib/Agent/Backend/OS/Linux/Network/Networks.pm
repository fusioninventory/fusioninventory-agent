package Ocsinventory::Agent::Backend::OS::Linux::Network::Networks;

use strict;

sub check {
  my @ifconfig = `ifconfig 2>/dev/null`;
  return 1 if @ifconfig;
  return;
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
  my $ipgateway;
  my $macaddr;
  my $status;
  my $type;


  foreach (`route`){
    $ipgateway=$1 if /^default\s+(\S+)/i;
  }

  foreach (`ifconfig -a`){
    if (/^$/ && $description !~ /^(lo|vmnet\d+|sit\d+)$/) {
      # end of interface section 
      # I write the entry

      $inventory->addNetworks({

	  DESCRIPTION => $description,
	  IPDHCP => _ipdhcp($description),
	  IPGATEWAY => $ipgateway,
	  MACADDR => $macaddr,
	  STATUS => $status?"Up":"Down",
	  TYPE => $type,

	});

      $description =  $ipgateway = $macaddr = $status =  $type = undef;
    }

      $description = $1 if /^(\S+)/; # Interface name
      $macaddr = $1 if /hwadd?r\s+(\S+)/i;
      $status = 1 if /^\s+UP\s/;
      $type = $1 if /link encap:(\S+)/i;

  }
}

1;
