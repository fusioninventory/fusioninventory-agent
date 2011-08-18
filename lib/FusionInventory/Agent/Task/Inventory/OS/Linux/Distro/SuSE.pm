package FusionInventory::Agent::Task::Inventory::OS::Linux::Distro::SuSE;

use strict;
use warnings;

use English qw(-no_match_vars);

# This module is used to detect SuSE's service pack level

sub isInventoryEnabled {
    return -f "/etc/SuSE-release";
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $handle;
    if (!open $handle, '<', "/etc/SuSE-release") {
        warn "Can't open /etc/SuSE-release: $ERRNO";
        return;
    }
    while (<$handle>) {
        if (/^PATCHLEVEL = ([0-9]+)/) {
			$inventory->setOperatingSystem({
                SERVICE_PACK => $1
            });
        }
    }
    close $handle;

}

1;
