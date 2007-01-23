package Ocsinventory::Agent::Backend::OS::Linux::Domains;
use strict;

sub check {
  my @domain = `hostname -d`;
  return 1 if @domain;
  -f "/etc/resolv.conf"
}
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $domain;

  chomp($domain = `hostname -d`);

  if (!$domain) {
    my %domain;

    open RESOLV, "/etc/resolv.conf" or warn;
    while(<RESOLV>){
      $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
    }
    close RESOLV;

    $domain = join "/", keys %domain;
  }

  # If no domain name, we send "WORKGROUP"
  $domain = 'WORKGROUP' unless $domain;

  $inventory->setHardware({
      WORKGROUP => $domain
    });

}

1;
