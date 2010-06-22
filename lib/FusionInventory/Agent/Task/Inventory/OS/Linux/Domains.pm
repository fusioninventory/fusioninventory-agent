package FusionInventory::Agent::Task::Inventory::OS::Linux::Domains;

use strict;
use warnings;

use Config;
use Sys::Hostname;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %domain;
    my @dns_list;
    my $dns;

    my $domain = $Config{mydomain};
    $domain = `hostname -d` unless $domain;

    chomp($domain);

    if (open my $handle, '<', '/etc/resolv.conf') {
        while(<$handle>){
            if (/^nameserver\s+(\S+)/i) {
                push(@dns_list,$1);
            }
            # Hackish... We should avoid that
            elsif (!$domain) {
                $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
            }
        }
        close $handle;
    } else {
        warn "Can't open /etc/resolv.conf: $ERRNO";
    }

    if (!$domain) {
        $domain = join "/", keys %domain;
    }

    $dns = join("/",@dns_list);
    # If no domain name, we send "WORKGROUP"
    $domain = 'WORKGROUP' unless $domain;

    $inventory->setHardware({
        WORKGROUP => $domain,
        DNS => $dns
    });

}

1;
