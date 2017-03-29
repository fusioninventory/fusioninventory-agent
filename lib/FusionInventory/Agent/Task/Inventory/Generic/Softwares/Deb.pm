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
        '${Installed-Size}\t'.
        '${Section}\n' .
        '\'';

    my $packages = _getPackagesList(
        logger => $logger, command => $command
    );
    return unless $packages;

    # mimic RPM inventory behaviour, as GLPI aggregates software
    # based on name and publisher
    my $publisher = getFirstMatch(
        logger  => $logger,
        pattern => qr/^Distributor ID:\s(.+)/,
        command => 'lsb_release -i',
    );

    foreach my $package (@$packages) {
        $package->{PUBLISHER} = $publisher;
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
            FROM        => 'deb',
            SYSTEM_CATEGORY => $infos[4]
        };
    }
    close $handle;

    return \@packages;
}

1;
