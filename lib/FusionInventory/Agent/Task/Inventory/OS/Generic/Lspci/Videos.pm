package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    # both windows and linux have dedicated modules
    return 
        $OSNAME ne 'MSWin32' &&
        $OSNAME ne 'linux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $video (_getVideoControllers(logger => $logger)) {
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video
        );
    }
}

sub _getVideoControllers {
    my @videos;

    foreach my $controller (getControllersFromLspci(@_)) {
        next unless $controller->{NAME} =~ /graphics|vga|video|display/i;
        push @videos, {
            CHIPSET => $controller->{NAME},
            NAME    => $controller->{MANUFACTURER},
        };
    }

    return @videos;
}

1;
