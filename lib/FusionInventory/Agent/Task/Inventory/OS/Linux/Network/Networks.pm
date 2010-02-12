package FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;

use strict;
use warnings;

sub isInventoryEnabled {
  return unless can_run("ifconfig") && can_run("route") && can_load("Net::IP qw(:PROC)");

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
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $logger = $params->{logger};

  my $description;
  my $driver;
  my $ipaddress;
  my $ipgateway;
  my $ipmask;
  my $ipsubnet;
  my $macaddr;
  my $pcislot;
  my $status;
  my $type;
  my $virtualdev;

  my %gateway;
  foreach (`route -n`) {
    if (/^(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/) {
      $gateway{$1} = $2;
    }
  }

  if (defined ($gateway{'0.0.0.0'})) {
    $inventory->setHardware({
        DEFAULTGATEWAY => $gateway{'0.0.0.0'}
      });
  }



  foreach my $line (`ifconfig -a`) {
    if ($line =~ /^$/ && $description && $ipaddress) {
      # end of interface section
      # I write the entry
      my $binip = ip_iptobin ($ipaddress ,4);
      my $binmask = ip_iptobin ($ipmask ,4);
      my $binsubnet = $binip & $binmask;
      $ipsubnet = ip_bintoip($binsubnet,4);

      my @wifistatus = `iwconfig $description 2>>/dev/null`;
      if ( @wifistatus > 2 ) {
        $type = "Wifi";
      }

      $ipgateway = $gateway{$ipsubnet};

      # replace '0.0.0.0' (ie 'default gateway') by the default gateway IP adress if it exists
      if (defined($ipgateway) and $ipgateway eq '0.0.0.0' and defined($gateway{'0.0.0.0'})) {
        $ipgateway = $gateway{'0.0.0.0'}
      }

      if (open UEVENT, "</sys/class/net/$description/device/uevent") {
        foreach (<UEVENT>) {
          $driver = $1 if /^DRIVER=(\S+)/;
          $pcislot = $1 if /^PCI_SLOT_NAME=(\S+)/;
        }
        close UEVENT;
      }

      # Reliable way to get the info
      if (-d "/sys/devices/virtual/net/") {
        $virtualdev = (-d "/sys/devices/virtual/net/$description")?"1":"0";
      } elsif (can_run("brctl")) {
        # Let's guess
        my %bridge;
        foreach (`brctl show`) {
          next if /^bridge name/;
          $bridge{$1} = 1 if /^(\w+)\s/;
        }
        if ($pcislot) {
          $virtualdev = "1";
        } elsif ($bridge{$description}) {
          $virtualdev = "0";
        }
      }

      $inventory->addNetwork({

          DESCRIPTION => $description,
          DRIVER => $driver,
          IPADDRESS => $ipaddress,
          IPDHCP => _ipdhcp($description),
          IPGATEWAY => $ipgateway,
          IPMASK => $ipmask,
          IPSUBNET => $ipsubnet,
          MACADDR => $macaddr,
          PCISLOT => $pcislot,
          STATUS => $status?"Up":"Down",
          TYPE => $type,
          VIRTUALDEV => $virtualdev,

        });

    }

    if ($line =~ /^$/) { # End of section

      $description = $driver = $ipaddress = $ipgateway = $macaddr = $pcislot = $status =  $type = $virtualdev = undef;

    } else { # In a section

      $description = $1 if $line =~ /^(\S+)/; # Interface name
      $ipaddress = $1 if $line =~ /inet addr:(\S+)/i;
      $ipmask = $1 if $line =~ /\S*mask:(\S+)/i;
      $macaddr = $1 if $line =~ /hwadd?r\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/i;
      $status = 1 if $line =~ /^\s+UP\s/;
      $type = $1 if $line =~ /link encap:(\S+)/i;
    }


  }
}
1;
