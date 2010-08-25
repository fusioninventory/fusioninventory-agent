package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::RPM;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("rpm");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $command =
        'rpm -qa --queryformat "' .
        '%{NAME}\t' .
        '%{VERSION}-%{RELEASE}\t' .
        '%{INSTALLTIME:date}\t' .
        '%{SIZE}\t' .
        '%{SUMMARY}\n' . 
        '" 2>/dev/null';

    my $packages = parseRpm($logger, $command, '-|');

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub parseRpm {
    my ($logger, $file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my $packages;

    while (my $line = <$handle>) {
        chomp $line;
        my @infos = split("\t", $line);
        push @$packages, {
            NAME        => $infos[0],
            VERSION     => $infos[1],
            INSTALLDATE => $infos[2],
            FILESIZE    => $infos[3],
            COMMENTS    => $infos[4],
            FROM        => 'rpm'
        };
    }

    close $handle;

    return $packages;
}


1;
