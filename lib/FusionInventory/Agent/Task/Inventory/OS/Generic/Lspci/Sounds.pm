package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Sounds;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $sound (_getSoundControllers(logger => $logger)) {
        $inventory->addEntry(
            section => 'SOUNDS',
            entry   => $sound
        );
    }
}

sub _getSoundControllers {
    my @sounds;

    foreach my $controller (getControllersFromLspci(@_)) {
        next unless $controller->{NAME} =~ /audio/i;
        push @sounds, {
            NAME         => $controller->{NAME},
            MANUFACTURER => $controller->{MANUFACTURER},
            DESCRIPTION  => "rev $controller->{VERSION}",
        };
    }

    return @sounds;
}

1;
