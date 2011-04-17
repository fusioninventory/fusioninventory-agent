package FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::RPM;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('rpm');
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

    my $packages = _getPackagesListFromRpm(
        logger => $logger, command => $command
    );
    foreach my $package (@$packages) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $package
        );
    }
}

sub _getPackagesListFromRpm {
    my $handle = getFileHandle(@_);

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
