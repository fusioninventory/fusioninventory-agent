package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('equery');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = 'equery list -i';

    my $packages = _getPackagesListFromEquery(
        logger => $logger, command => $command
    );

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _getPackagesListFromEquery {
    my $handle = getFileHandle(@_);

    my @packages;
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /^([a-z]\w+-\w+\/\w+)-([0-9]+.*)/;
        push @packages, {
            NAME    => $1,
            VERSION => $2,
        };
    }
    close $handle;

    return \@packages;
}

1;
