package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('equery');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $packages = _parseEquery($logger);

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub _parseEquery {
    my ($logger, $file) = @_;

    my $command = 'equery list -i 2>/dev/null';
    my $callback = sub {
        my ($line) = @_;
        return unless $line =~ /^([a-z]\w+-\w+\/\w+)-([0-9]+.*)/;
        return {
            NAME    => $1,
            VERSION => $2,
        };
    };

    return $file ?
        getPackagesFromCommand($logger, $file, '<', $callback)    :
        getPackagesFromCommand($logger, $command, '-|', $callback);
}

1;
