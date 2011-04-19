package FusionInventory::Agent::Task::Inventory::OS::AIX::Modems;

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

    foreach my $modem (_getModems(
        command => 'lsdev -Cc adapter -F "name:type:description"',
        logger  => $logger,
    )) {
        $inventory->addEntry(
            section => 'MODEMS',
            entry   => $modem,
        );
    }
}

sub _getModems {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @modems;
    while (my $line = <$handle>) {
        next unless $line =~ /modem/i;
        next unless $line =~ /\d+\s(.+):(.+)$/;
        push @modems, {
            NAME        => $1,
            DESCRIPTION => $2
        };
    }
    close $handle;

    return @modems;
}

1;
