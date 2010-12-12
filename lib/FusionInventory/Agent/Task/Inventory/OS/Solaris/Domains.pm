package FusionInventory::Agent::Task::Inventory::OS::Solaris::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);
use Sys::Hostname;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('domainname');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

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

    # attempt to deduce the domain from the domainname command
    my $domain = `domainname`;
    chomp $domain;

    # fallback on the host name
    if (!$domain) {
        my $hostname = hostname();
        my $pos = index $hostname, '.';

        if ($pos >= 0) {
            $domain = substr($hostname, $pos + 1);
        }
    }

    # fallback on the domain search list
    if (!$domain) {
        $domain = join('/', @search_list);
    }

    $inventory->setHardware(
        WORKGROUP => $domain,
        DNS       => $dns
    );
}

1;
