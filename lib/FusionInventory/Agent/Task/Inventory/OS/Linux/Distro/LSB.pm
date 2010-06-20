package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run("lsb_release");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $release;
    foreach (`lsb_release -d`) {
        $release = $1 if /Description:\s+(.+)/;
    }
    my $OSComment;
    chomp($OSComment =`uname -v`);

    $inventory->setHardware({ 
        OSNAME => $release,
        OSCOMMENTS => "$OSComment"
    });
}



1;
