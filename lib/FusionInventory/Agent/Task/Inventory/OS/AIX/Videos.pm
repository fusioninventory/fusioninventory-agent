package FusionInventory::Agent::Task::Inventory::OS::AIX::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $video (_getVideos(
        command => 'lsdev -Cc adapter -F "name:type:description"',
        logger  => $logger
    )) {
        $inventory->addEntry(
            section => 'VIDEOS',
            entry   => $video
        );
    }
}

sub _getVideos {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @videos;
    while (my $line = <$handle>) {
        next unless $line =~ /graphics|vga|video/i;
        next unless $line =~ /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/;
        push @videos, {
            CHIPSET => $1,
            NAME    => $2,
        };
    }
    close $handle;

    return @videos;
}

1;
