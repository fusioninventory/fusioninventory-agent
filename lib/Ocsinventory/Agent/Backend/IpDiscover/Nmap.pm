package Ocsinventory::Agent::Backend::IpDiscover::Nmap;

use strict;
use warnings;

sub check {
  my $params = shift;

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


sub run {
  my $params = shift;

  my $inventory = $params->{inventory};
  my $prologresp = $params->{prologresp};

  my $options = $prologresp->getOptionInfoByName("IPDISCOVER");

  my $network = $options->{content};


  foreach (`nmap -sP -PR '$network/24'`) {


  }
}

1;
