package FusionInventory::Agent::Task::Inventory::OS::Linux::Softwares::Slackware;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('pkgtool');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getDirectoryHandle(
        directory => '/var/log/packages', logger => $logger
    );
    return unless $handle;

    while (my $file = readdir($handle)) {
        next unless $file =~ /^(.+)([^-]+-[^-]+-[^-]+)$/;
        my $name = $1;
        my $version = $2;

        $inventory->addSoftware({
            NAME    => $name,
            VERSION => $version
        });
    }
    closedir $handle;
}

1;
