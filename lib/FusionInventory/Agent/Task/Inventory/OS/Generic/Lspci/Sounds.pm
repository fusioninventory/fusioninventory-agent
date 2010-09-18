package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Sounds;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $sounds = _getSoundControllers($logger);

    return unless $sounds;

    foreach my $sound (@$sounds) {
        $inventory->addSound($sound);
    }
}

sub _getSoundControllers {
    my ($logger, $file) = @_;

    my $controllers = getControllersFromLspci($logger, $file);
    my $sounds;

    foreach my $controller (@$controllers) {
        next unless $controller->{NAME} =~ /audio/i;
        push @$sounds, {
            NAME         => $controller->{NAME},
            MANUFACTURER => $controller->{MANUFACTURER},
            DESCRIPTION  => "rev $controller->{VERSION}",
        };
    }

    return $sounds;
}

1;
