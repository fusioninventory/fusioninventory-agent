package FusionInventory::Agent::Task::Inventory::IpDiscover::IpDiscover;

use strict;
use warnings;

sub isInventoryEnabled { can_run ("ipdiscover") }

sub doInventory {
  my $params = shift;

  my $inventory = $params->{inventory};
  my $prologresp = $params->{prologresp};
  my $logger = $params->{logger};

  # Let's find network interfaces and call ipdiscover on it
  my $options = $prologresp->getOptionsInfoByName("IPDISCOVER");
  my $ipdisc_lat;
  my $network;
  if ($options->[0] && exists($options->[0]->{IPDISC_LAT}) && $options->[0]->{IPDISC_LAT}) {
    $ipdisc_lat = $options->[0]->{IPDISC_LAT};
  }

  if ($options->[0] && exists($options->[0]->{content})) {
    $network = $options->[0]->{content};
  } else {
    return;
  }
  $logger->debug("scanning the $network network");

  my $legacymode;
  if( `ipdiscover` =~ /binary ver. (\d+)/ ){
    if(!($1>3)) {
      $legacymode = 1;
      $logger->debug("ipdiscover ver.$1: legacymode");
    }
  }


  my $ifname;
  foreach (`route -n`) {
      if (/^(\d+\.\d+\.\d+\.\d+).*?\s(\S+)$/) {
          if ($network eq $1) {
              $ifname = $2;
              last;
          } elsif (!$ifname && $1 eq "0.0.0.0") {
              $ifname = $2;
          }
      }
  }

  my $cmd = "ipdiscover $ifname ";
  $cmd .= $ipdisc_lat if ($ipdisc_lat && !$legacymode);

  foreach (`$cmd`) {
    if (/<H><I>([\d\.]*)<\/I><M>([\w\:]*)<\/M><N>(\S*)<\/N><\/H>/) {
      $inventory->addIpDiscoverEntry({
        IPADDRESS => $1,
        MACADDR => $2,
        NAME => $3
      });
    }
  }
}

1;
