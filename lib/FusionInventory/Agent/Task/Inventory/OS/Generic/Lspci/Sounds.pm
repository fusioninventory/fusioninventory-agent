package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Sounds;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $sounds = parseLspci('/usr/bin/lspci', '-|');

    return unless $sounds;

    foreach my $sound (@$sounds) {
        $inventory->addSound($sound);
    }
}

sub parseLspci {
    my ($file, $mode) = @_;

     my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $sounds;

    while (my $line = <$handle>) {
        chomp $line;

        next unless $line =~ /audio/i;
        next unless $line =~ /^\S+ \s ([^:]+) : \s (.+?) (?:\(([^)]+)\))?$/x;
        push(@$sounds, {
            NAME         => $1,
            MANUFACTURER => $2,
            DESCRIPTION  => $3
        });
    }

    return $sounds;
}

1;
