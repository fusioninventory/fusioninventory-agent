package FusionInventory::Agent::Task::Inventory::AIX::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{video};
    return canRun('lsdev');
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
