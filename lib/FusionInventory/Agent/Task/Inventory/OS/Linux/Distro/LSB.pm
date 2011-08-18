package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::LSB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun("lsb_release");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $release = getFirstMatch(
        logger  => $logger,
        command => 'lsb_release -d',
        pattern => qr/Description:\s+(.+)/
    );

    my $linuxDistributionName;
    my $linuxDistributionVersion;
    # Redirect stderr to /dev/null to avoid "No LSB modules are available" message
    foreach (`lsb_release -a 2> /dev/null`) {
        $linuxDistributionName    = $1 if /Distributor ID:\s+(.+)/;
        $linuxDistributionVersion = $1 if /Release:\s+(.+)/;
    }

    $inventory->setHardware({
        OSNAME     => $release,
    });

    $inventory->setOS({
        NAME                 => $linuxDistributionName,
        VERSION              => $linuxDistributionVersion,
        FULL_NAME            => $release
    });

}

1;
