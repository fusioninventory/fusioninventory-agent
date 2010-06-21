package FusionInventory::Agent::Task::Inventory::OS::Solaris::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return can_run ("domainname");
}

sub doInventory { 
    my $params = shift;
    my $inventory = $params->{inventory};

    my $domain;

    chomp($domain = `domainname`);

    if (!$domain) {
        my %domain;

        if (open my $handle, '<', '/etc/resolv.conf') {
            while(<$handle>) {
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
