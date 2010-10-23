package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Deb;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return can_run("dpkg");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $packages = _parseDpkg($logger);

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parseDpkg {
    my ($logger, $file) = @_;

    my $command =
        'dpkg-query --show --showformat="' .
        '${Package}\t' .
        '${Version}\t'.
        '${Installed-Size}\t' .
        '${Description}\n' .
        '" 2>/dev/null';
    my $callback = sub {
        my ($line) = @_;
        my @infos = split("\t", $line);
        return {
            NAME        => $infos[0],
            VERSION     => $infos[1],
            FILESIZE    => $infos[2],
            COMMENTS    => $infos[3],
            FROM        => 'deb'
        };
    };

    return $file ?
        getPackagesFromCommand($logger, $file, '<', $callback)    :
        getPackagesFromCommand($logger, $command, '-|', $callback);
}

1;
