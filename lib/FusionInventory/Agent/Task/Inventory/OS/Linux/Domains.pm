package FusionInventory::Agent::Task::Inventory::OS::Linux::Domains;
use strict;

sub isInventoryEnabled {
  return 1 if can_load ("Sys::Hostname") or can_read ("/etc/resolv.conf");
  0;
}
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $domain = $Sys::Hostname::hostname;
  my %domain;
  my @dns_list;
  my $dns;

  $domain =~ s/\..*//;

  open RESOLV, "/etc/resolv.conf" or warn;
    while(<RESOLV>){
      if (/^nameserver\s+(\S+)/i) {
        push(@dns_list,$1);
      }
      elsif (!$domain) {
        $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
      }
    }
  close RESOLV;

  if (!$domain) {
    $domain = join "/", keys %domain;
  }
  
  $dns=join("/",@dns_list);
  # If no domain name, we send "WORKGROUP"
  $domain = 'WORKGROUP' unless $domain;

  $inventory->setHardware({
      WORKGROUP => $domain,
      DNS => $dns
    });

}

1;
