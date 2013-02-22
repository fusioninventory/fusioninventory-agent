package FusionInventory::Agent::Task::Inventory::Generic::Domains;

use strict;
use warnings;

use Sys::Hostname;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return -f "/etc/resolv.conf";
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # first, parse /etc/resolv.conf for the DNS servers,
    # and the domain search list
    my %dns_list;
    my %search_list;
    my $handle = getFileHandle(
        file => '/etc/resolv.conf',
        logger => $logger
    );
    if ($handle) {
        while (my $line = <$handle>) {
            if ($line =~ /^nameserver\s+(\S+)/) {
                $dns_list{$1} = 1;
            } elsif ($line =~ /^(domain|search)\s+(\S+)/) {
                $search_list{$2} = 1;
            }
        }
        close $handle;
    }

    my $dns = join('/', keys %dns_list);

    # attempt to deduce the actual domain from the host name
    # and fallback on the domain search list
    my $domain;
    my $hostname = hostname();
    my $pos = index $hostname, '.';

    if ($pos >= 0) {
        $domain = substr($hostname, $pos + 1);
    } else {
        $domain = join('/', keys %search_list);
    }

    $inventory->setHardware({
        WORKGROUP => $domain,
        DNS       => $dns
    });

}

1;
