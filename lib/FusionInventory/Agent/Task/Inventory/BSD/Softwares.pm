package FusionInventory::Agent::Task::Inventory::BSD::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{software} &&
        canRun('pkg_info');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = 'pkg_info';
    my $packages = _getPackagesListFromPkgInfo(
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
        next unless $line =~ /^(\S+) - (\S+) \s+ (.*)/x;
        push @packages, {
            NAME     => $1,
            VERSION  => $2,
            COMMENTS => $3
        };
    }

    close $handle;

    return \@packages;
}

1;
