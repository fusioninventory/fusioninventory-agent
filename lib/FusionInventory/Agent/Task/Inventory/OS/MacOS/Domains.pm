package FusionInventory::Agent::Task::Inventory::OS::MacOS::Domains;

use strict;
use warnings;

use Sys::Hostname;

use English qw(-no_match_vars);
use Sys::Hostname;

# straight up theft from the other modules...

sub isInventoryEnabled {
    my $hostname = hostname();
    return 
        (index $hostname, '.' >= 0) || # look for a dot in hostname
        -f "/etc/resolv.conf"
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    # first, parse /etc/resolv.conf for the DNS servers,
    # and the domain search list
    my @dns_list;
    my @search_list;
    if (open my $handle, '<', '/etc/resolv.conf') {
        while (my $line = <$handle>) {
            if ($line =~ /^nameserver\s+(\S+)/) {
                push(@dns_list, $1);
            } elsif ($line =~ /^(domain|search)\s+(\S+)/) {
                push(@search_list, $1);
            }
        }
        close $handle;
    } else {
        $logger->debug("Can't open /etc/resolv.conf: $ERRNO");
    }
    my $dns = join('/', @dns_list);

    # attempt to deduce the actual domain from the host name
    # and fallback on the domain search list
    my $domain;
    my $hostname = hostname();
    my $pos = index $hostname, '.';

    if ($pos >= 0) {
        $domain = substr($hostname, $pos + 1);
    } else {
        $domain = join('/', @search_list);
    }

    $inventory->setHardware({
        WORKGROUP => $domain,
        DNS => $dns
    });

}

1;
