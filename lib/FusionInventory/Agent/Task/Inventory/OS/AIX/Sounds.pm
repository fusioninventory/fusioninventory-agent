package FusionInventory::Agent::Task::Inventory::OS::AIX::Sounds;

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

    foreach my $sound (_getSounds(
        command => 'lsdev -Cc adapter -F "name:type:description"',
        logger  => $logger
    )) {
        $inventory->addEntry(
            section => 'SOUNDS',
            entry   => $sound
        );
    }

}

sub _getSounds {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @sounds;
    while (my $line = <$handle>) {
        next unless $line =~ /audio/i;
        next unless $line =~ /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/;
        push @sounds, {
            NAME         => $1,
            MANUFACTURER => $2,
            DESCRIPTION  => $3,
        };
    }
    close $handle;

    return @sounds;
}

1;
