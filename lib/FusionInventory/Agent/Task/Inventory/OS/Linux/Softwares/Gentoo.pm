package FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    return can_run('equery');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = _equeryNeedsWildcard('equery -v', '-|') ?
        "equery list -i '*'" : "equery list -i";

    my $packages = _getPackagesList(
        logger => $logger, command => $command
    );

    foreach my $package (@$packages) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $package
        );
    }
}

sub _getPackagesList {
    my $handle = getFileHandle(@_);

    my @packages;
    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /^(.*)-([0-9]+.*)/;
        push @packages, {
            NAME    => $1,
            VERSION => $2,
        };
    }
    close $handle;

    return \@packages;
}

# http://forge.fusioninventory.org/issues/852
sub _equeryNeedsWildcard {
    my $version = getFirstLine(command => 'equery -v');
    my ($major, $minor) = $version =~ /^equery \((\d+)\.(\d+)\.\d+\)/;

    # true starting from version 0.3
    return compareVersion($major, $minor, 0, 3);
}

1;
