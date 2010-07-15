package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Videos;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $videos = parseLspci('/usr/bin/lspci', '-|');

    return unless $videos;

    foreach my $video (@$videos) {
        $inventory->addVideo($video);
    }
}

sub parseLspci {
    my ($file, $mode) = @_;

     my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $videos;

    while (my $line = <$handle>) {
        chomp $line;

        next unless $line =~ /graphics|vga|video/i;
        next unless $line =~ /^\S+ \s ([^:]+) : \s (.+?) (?:\(([^)]+)\))?$/x;
        push(@$videos, {
            CHIPSET => $1,
            NAME    => $2,
        });
    }

    return $videos;
}

1;
