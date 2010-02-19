package FusionInventory::Agent::Task::Inventory::OS::HPUX::Domains;
use strict;

sub isInventoryEnabled { return can_run ("domainname") }

sub isInventoryEnabled {
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
