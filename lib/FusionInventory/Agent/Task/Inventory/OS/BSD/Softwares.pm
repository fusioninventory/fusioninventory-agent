package FusionInventory::Agent::Task::Inventory::OS::BSD::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my (%params) = @_;

    return
        !$params{config}->{no_software} &&
        can_run('pkg_info');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = 'pkg_info';
    my $packages = _getPackagesFromPkgInfo(
        logger => $logger, command => $command
    );

    foreach my $package (@$packages) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $package
        );
    }
}

sub _getPackagesListFromPkgInfo {
    my $handle = getFileHandle(@_);

    my @packages;
    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+)-(\d+\S*)\s+(.*)/;
        push @packages, {
            NAME    => $1,
            VERSION => $2,
            VERSION => $3
        };
    }

    close $handle;

    return \@packages;
}

1;
