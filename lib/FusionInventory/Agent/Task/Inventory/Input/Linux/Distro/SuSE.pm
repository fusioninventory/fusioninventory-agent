package FusionInventory::Agent::Task::Inventory::Input::Linux::Distro::SuSE;

use strict;
use warnings;

use English qw(-no_match_vars);
use FusionInventory::Agent::Tools;

# This module is used to detect SuSE's service pack level

sub isEnabled {
    return canRead('/etc/SuSE-release');
}

sub doInventory {
    my (%params) = @_;
    my $inventory = $params{inventory};

    my $service_pack  = getFirstMatch(
            file    => '/etc/SuSE-release',
            pattern => qr/^PATCHLEVEL = ([0-9]+)/
        );
    $inventory->setOperatingSystem({ SERVICE_PACK => $service_pack});

}

1;
