package Ocsinventory::Agent::Backend::OS::Solaris::Domains;
use strict;

sub check { can_run ("domainname") }

sub run { 
  my $params = shift;
  my $inventory = $params->{inventory};

  my $domain;

  chomp($domain = `domainname`);

  if (!$domain) {
    my %domain;

    if (open RESOLV, "/etc/resolv.conf") {
      while(<RESOLV>) {
	$domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
      }
      close RESOLV;
    }
    $domain = join "/", keys %domain;
  }
# If no domain name, we send "WORKGROUP"
  $domain = 'WORKGROUP' unless $domain;
  $inventory->setHardware({
      WORKGROUP => $domain
      });
}

1;
