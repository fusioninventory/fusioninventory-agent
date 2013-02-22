package FusionInventory::Agent::Task::Inventory::Generic::Softwares::Deb;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('dpkg-query');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command =
        'dpkg-query --show --showformat=\'' .
        '${Package}\t' .
        '${Architecture}\t' .
        '${Version}\t'.
        '${Installed-Size}\t' .
        '${Description}\n' .
        '\'';

    my $packages = _getPackagesList(
        logger => $logger, command => $command
    );
    return unless $packages;

    foreach my $package (@$packages) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $package
        );
    }
}

sub _getPackagesList {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @packages;
    while (my $line = <$handle>) {
        # skip descriptions
        next if $line =~ /^ /;
        chomp $line;
        my @infos = split("\t", $line);
        push @packages, {
            NAME        => $infos[0],
            ARCH        => $infos[1],
            VERSION     => $infos[2],
            FILESIZE    => $infos[3],
            COMMENTS    => $infos[4],
            FROM        => 'deb'
        };
    }
    close $handle;

    return \@packages;
}

1;
