package Ocsinventory::Agent::Backend::OS::Linux::Domains;
use strict;

sub check {
  return unless can_run ("hostname");
  my @domain = `hostname -d`;
  return 1 if @domain || can_read ("/etc/resolv.conf");
  0;
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
         if (/^(domain|search)\s+(.+)/) {
               foreach (split(/\s+/,$2)) {
                       $domain{$_} = 1;
               }
         }
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
