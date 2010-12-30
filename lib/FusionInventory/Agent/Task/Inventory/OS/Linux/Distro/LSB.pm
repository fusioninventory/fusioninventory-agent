package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsb_release');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $release;
    foreach (`lsb_release -d`) {
        $release = $1 if /Description:\s+(.+)/;
    }
    my $OSComment = getFirstLine(command => 'uname -v');

    $inventory->setHardware(
        OSNAME     => $release,
        OSCOMMENTS => $OSComment
    );
}

1;
