package FusionInventory::Agent::Task::Inventory::Input::Generic::Softwares::RPM;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('rpm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command =
        'rpm -qa --queryformat \'' .
        '%{NAME}\t' .
        '%{VERSION}-%{RELEASE}\t' .
        '%{INSTALLTIME:date}\t' .
        '%{SIZE}\t' .
        '%{VENDOR}\t' .
        '%{SUMMARY}\n' . 
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
        chomp $line;
        my @infos = split("\t", $line);
        push @packages, {
            NAME        => $infos[0],
            VERSION     => $infos[1],
            INSTALLDATE => $infos[2],
            FILESIZE    => $infos[3],
            PUBLISHER   => $infos[4],
            COMMENTS    => $infos[5],
            FROM        => 'rpm'
        };
    }

    close $handle;

    return \@packages;
}

1;
