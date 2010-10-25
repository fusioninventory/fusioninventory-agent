package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $videos = _getVideoControllers($logger);
    
    return unless $videos;

    foreach my $video (@$videos) {
        $inventory->addVideo($video);
    }
}

sub _getVideoControllers {
     my ($logger, $file) = @_;

    my $controllers = getControllersFromLspci(logger => $logger, file => $file);
    my $videos;

    foreach my $controller (@$controllers) {
        next unless $controller->{NAME} =~ /graphics|vga|video|display/i;
        push @$videos, {
            CHIPSET => $controller->{NAME},
            NAME    => $controller->{MANUFACTURER},
        };
    }

    return $videos;
}

1;
