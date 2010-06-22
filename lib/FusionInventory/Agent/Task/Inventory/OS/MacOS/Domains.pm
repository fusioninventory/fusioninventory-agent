package FusionInventory::Agent::Task::Inventory::OS::MacOS::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);
use Sys::Hostname;

# straight up theft from the other modules...

sub isInventoryEnabled {
    my $hostname = hostname();

    return 
        index $hostname, '.' >= 0 || # a simple dot in hostname
        -f "/etc/resolv.conf";
}
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $domain;
    my $hostname = hostname();
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
