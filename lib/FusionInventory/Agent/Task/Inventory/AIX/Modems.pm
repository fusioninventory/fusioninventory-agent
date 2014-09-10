package FusionInventory::Agent::Task::Inventory::AIX::Modems;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{modem};
    return canRun('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $modem (_getModems(
        logger  => $logger,
    )) {
        $inventory->addEntry(
            section => 'MODEMS',
            entry   => $modem,
        );
    }
}

sub _getModems {
    my @adapters = getAdaptersFromLsdev(@_);

    my @modems;
    foreach my $adapter (@adapters) {
        next unless $adapter->{DESCRIPTION} =~ /modem/i;
        push @modems, {
            NAME        => $adapter->{NAME},
            DESCRIPTION => $adapter->{DESCRIPTION},
        };
    }

    return @modems;
}

1;
