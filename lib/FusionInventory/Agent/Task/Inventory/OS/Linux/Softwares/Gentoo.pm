package FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::Gentoo;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('equery');
}

# http://forge.fusioninventory.org/issues/852
sub _equeryNeedsWildcard {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "can't open $file: $ERRNO";
        return;
    }
    chomp(my $line = <$handle>);
    if ($line =~ /^equery \(([\d\.]+)\)/) {
        my @v = split(/\./, $1);
        return 1 if $v[0] > 0;
        return if $v[1] < 3;
        return 1;
    }

    return;
}


sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $command = 'equery list -i';
    if (_equeryNeedsWildcard('equery -v', '-|')) {
        $command .= " '*'";
    }


    my $packages = _getPackagesListFromEquery(
        logger => $logger, command => $command
    );

    foreach my $package (@$packages) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $package
        );
    }
}

sub _getPackagesListFromEquery {
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

1;
