package Ocsinventory::Agent::Backend::IpDiscover::IpDiscover;

use strict;
use warnings;

sub check {
  my $params = shift;

  # Do we have ipdiscover?
  `ipdiscover 2>&1`;
  if (($? >> 8)==0) {
    return 1; 
  }

  0;
}


sub run {
  my $params = shift;

  my $inventory = $params->{inventory};
  my $prologresp = $params->{prologresp};
  my $logger = $params->{logger};

  # Let's find network interfaces and call ipdiscover on it
  my $options = $prologresp->getOptionInfoByName("IPDISCOVER");
  my $ipdisc_lat;
  my $network;
  if (exists($options->{IPDISC_LAT}) && $options->{IPDISC_LAT}) {
    $ipdisc_lat = $options->{IPDISC_LAT};
  }

  if (exists($options->{content})) {
    $network = $options->{content};
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
