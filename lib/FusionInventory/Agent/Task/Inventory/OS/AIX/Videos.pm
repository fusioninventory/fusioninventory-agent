package FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $video (_getVideos(
        logger  => $logger
    )) {
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video
        );
    }
}

sub _getVideos {
    my @adapters = getAdaptersFromLsdev(@_);

    my @videos;
    foreach my $adapter (@adapters) {
        next unless $adapter->{DESCRIPTION} =~ /graphics|vga|video/i;
        push @videos, {
            NAME => $adapter->{NAME},
        };
    }

    return @videos;
}

1;
