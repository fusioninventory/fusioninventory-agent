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

    my $packages = _parseRpm($logger);

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parseRpm {
    my ($logger, $file) = @_;

    my $command =
        'rpm -qa --queryformat "' .
        '%{NAME}\t' .
        '%{VERSION}-%{RELEASE}\t' .
        '%{INSTALLTIME:date}\t' .
        '%{SIZE}\t' .
        '%{SUMMARY}\n' . 
        '" 2>/dev/null';
    my $callback = sub {
        my ($line) = @_;
        my @infos = split("\t", $line);
        return {
            NAME        => $infos[0],
            VERSION     => $infos[1],
            INSTALLDATE => $infos[2],
            FILESIZE    => $infos[3],
            COMMENTS    => $infos[4],
            FROM        => 'rpm'
        };
    };

    return $file ?
        getPackagesFromCommand($logger, $file, '<', $callback)    :
        getPackagesFromCommand($logger, $command, '-|', $callback);

}


1;
