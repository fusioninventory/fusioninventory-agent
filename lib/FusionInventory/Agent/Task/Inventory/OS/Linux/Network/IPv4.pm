package FusionInventory::Agent::Task::Inventory::OS::Linux::Network::IPv4;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run ("ifconfig");
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my @ip;
    foreach (`ifconfig`){
        if(/^\s*inet add?r\s*:\s*(\S+)/){
            ($1=~/127.+/)?next:push @ip, $1
        };
    }

    my $ip=join "/", @ip;

    $inventory->setHardware({IPADDR => $ip});
}

1;
