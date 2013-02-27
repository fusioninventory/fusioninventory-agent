package FusionInventory::Agent::Task::Inventory::Linux::Distro::LSB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('lsb_release');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'lsb_release -a',
    );

    my ($name, $version, $description);
    while (my $line = <$handle>) {
        $name        = $1 if $line =~ /^Distributor ID:\s+(.+)/;
        $version     = $1 if $line =~ /^Release:\s+(.+)/;
        $description = $1 if $line =~ /^Description:\s+(.+)/;
    }
    close $handle;

    # See: #1262
    $description =~ s/^Enterprise Linux Enterprise Linux/Oracle Linux/;

    $inventory->setHardware({
        OSNAME => $description,
    });

    $inventory->setOperatingSystem({
        NAME      => $name,
        VERSION   => $version,
        FULL_NAME => $description
    });

}

1;
