package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $videos = getVideoControllers();
    
    return unless $videos;

    foreach my $video (@$videos) {
        $inventory->addVideo($video);
    }
}

sub getVideoControllers {
     my ($file) = @_;

    my $controllers = getControllersFromLspci($file);
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
