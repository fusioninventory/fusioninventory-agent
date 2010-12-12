package FusionInventory::Agent::Task::Inventory::OS::MacOS::IPv4;

use strict;
use warnings;

# straight up theft from the other modules

sub isInventoryEnabled {
    return can_run('ifconfig');
}

# Initialise the distro entry
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my @ip;

    # Looking for ip addresses with ifconfig, except loopback
    # *BSD need -a option
    foreach (`ifconfig -a`){
      if(/^\s*inet\s+(\S+)/){
        ($1=~/127.+/)?next:push @ip, $1
      };
    }

    my $ip=join "/", @ip;

    $inventory->setHardware(IPADDR => $ip);
}

1;
