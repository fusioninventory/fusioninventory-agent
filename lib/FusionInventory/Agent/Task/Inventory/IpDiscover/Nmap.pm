package FusionInventory::Agent::Task::Inventory::IpDiscover::Nmap;

use vars qw($runMeIfTheseChecksFailed);
$runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::IpDiscover::IpDiscover"];
use strict;
use warnings;

sub isInventoryEnabled {
  my $params = shift;

  return unless can_run("nmap");

  # Do we have nmap 3.90 (or >) 
  foreach (`nmap -v 2>&1`) {
    if (/^Starting Nmap (\d+)\.(\d+)/) {
      my $release = $1;
      my $minor = $2;

      if ($release > 3 || ($release > 3 && $minor >= 90)) {
        return 1;
      }
    }
  }

  0;
}


sub doInventory {
  my $params = shift;

  my $inventory = $params->{inventory};
  my $prologresp = $params->{prologresp};
  my $logger = $params->{logger};

  # Let's find network interfaces and call ipdiscover on it
  my $options = $prologresp->getOptionsInfoByName("IPDISCOVER");

  my $network;
  if ($options->[0] && exists($options->[0]->{content})) {
    $network = $options->[0]->{content};
  } else {
    return;
  }
  $logger->debug("scanning the $network network");

  my $ip;
  my $cmd = "nmap -sP -PR $network/24";
  foreach (`$cmd`) {
      print;
      if (/^Host (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
          $ip = $1;
      } elsif (/MAC Address: (\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/) {
          $inventory->addIpDiscoverEntry({
             IPADDRESS => $ip,
                MACADDR => lc($1),
             });
      }
  }
}

1;
