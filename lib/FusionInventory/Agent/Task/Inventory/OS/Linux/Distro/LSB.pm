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

    my $linuxDistributionName;
    my $linuxDistributionVersion;
    # Redirect stderr to /dev/null to avoid "No LSB modules are available" message
    foreach (`lsb_release -a 2> /dev/null`) {
        $linuxDistributionName    = $1 if /Distributor ID:\s+(.+)/;
        $linuxDistributionVersion = $1 if /Release:\s+(.+)/;
    }

    my $OSComment;
    chomp($OSComment =`uname -v`);

    $inventory->setHardware({ 
        OSNAME => $release,
        OSCOMMENTS => "$OSComment"
    });

    $inventory->setOperatingSystem({
        NAME                 => "$linuxDistributionName",
        VERSION              => "$linuxDistributionVersion",
        FULL_NAME            => $release
    });

}



1;
