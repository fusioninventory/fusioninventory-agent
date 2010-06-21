package FusionInventory::Agent::Task::Inventory::OS::BSD::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);

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
    my %domain;
    my @dns_list;
    my $dns;
    my $hostname;
    chomp ($hostname = `hostname`);
    my @domain = split (/\./, $hostname);
    shift (@domain);
    $domain = join ('.',@domain);

    if (open my $handle, '<', '/etc/resolv.conf') {
        while(<$handle>){
            if (/^nameserver\s+(\S+)/i) {
                push(@dns_list,$1);
            }
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

    $dns=join("/",@dns_list);

# If no domain name, we send "WORKGROUP"
    $domain = 'WORKGROUP' unless $domain;

    $inventory->setHardware({
            WORKGROUP => $domain,
            DNS => $dns
        });

}

1;
