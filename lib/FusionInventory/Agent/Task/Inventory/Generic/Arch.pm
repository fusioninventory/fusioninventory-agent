package FusionInventory::Agent::Task::Inventory::Generic::Arch;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

sub isEnabled {
    return canRun('arch');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $arch = getFirstLine( command => 'arch' );

    $inventory->setOperatingSystem({
        ARCH     => $arch
    });

}

1;
