package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Deb;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run("dpkg");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $command =
        'dpkg-query --show --showformat="' .
        '${Package}\t' .
        '${Version}\t'.
        '${Installed-Size}\t' .
        '${Description}\n' .
        '" 2>/dev/null';

    my $packages = parseDpkg($command, '-|');

    foreach my $package (@$packages) {
        $inventory->addSoftware($package);
    }
}

sub parseDpkg {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $packages;

    while (my $line = <$handle>) {
        chomp $line;
        my @infos = split("\t", $line);
        push @$packages, {
            NAME        => $infos[0],
            VERSION     => $infos[1],
            FILESIZE    => $infos[2],
            COMMENTS    => $infos[3],
            FROM        => 'deb'
        };
    }

    close $handle;

    return $packages;
}

1;
