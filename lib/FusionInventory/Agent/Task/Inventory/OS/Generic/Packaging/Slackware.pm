package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::Slackware;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('pkgtool');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    opendir my $handle, '/var/log/packages/';
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
