package FusionInventory::Agent::Task::Inventory::OS::MacOS::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);

# straight up theft from the other modules...

sub isInventoryEnabled {
    my $hostname;
    chomp ($hostname = `hostname`);
    my @domain = split (/\./, $hostname);
    shift (@domain);
    return 1 if @domain;
    -f "/etc/resolv.conf"
 }
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $domain;
    my $hostname;
    chomp ($hostname = `hostname`);
    my @domain = split (/\./, $hostname);
    shift (@domain);
    $domain = join ('.',@domain);

    if (!$domain) {
      my %domain;

      if (open my $handle, '<', '/etc/resolv.conf') {
          while(<$handle>){
            $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
          }
          close $handle;
      } else {
          warn "Can't open /etc/resolv.conf: $ERRNO";
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
