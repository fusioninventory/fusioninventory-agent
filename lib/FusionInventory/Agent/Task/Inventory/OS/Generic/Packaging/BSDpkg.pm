package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::BSDpkg;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("pkg_info");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $packages = _parsePkgInfo($logger);

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parsePkgInfo {
    my ($logger, $file) = @_;

    my $command = 'pkg_info';
    my $callback = sub {
        my ($line) = @_;
        return unless $line =~ /^(\S+)-(\d+\S*)\s+(.*)/;
        return {
            NAME    => $1,
            VERSION => $2,
            VERSION => $3
        };
    };

    return $file ?
        getPackagesFromCommand($logger, $file, '<', $callback)    :
        getPackagesFromCommand($logger, $command, '-|', $callback);
}

1;
