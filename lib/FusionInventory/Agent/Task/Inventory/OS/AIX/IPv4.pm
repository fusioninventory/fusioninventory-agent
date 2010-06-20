package FusionInventory::Agent::Task::Inventory::OS::AIX::IPv4;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("ifconfig");
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my @ip;

    #Looking for ip addresses with ifconfig, except loopback
    # AIX need -a option
    for(`ifconfig -a`){#ifconfig in the path
        # AIX ligne inet
        if(/^\s*inet\s+(\S+).*/){($1=~/127.+/)?next:push @ip, $1};
    }
    my $ip=join "/", @ip;
    $inventory->setHardware({IPADDR => $ip});
}

1;
