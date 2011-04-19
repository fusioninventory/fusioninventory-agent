package FusionInventory::Agent::Task::Inventory::OS::AIX::Controllers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('lsdev');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $controller (_getControllers(
        command => 'lsdev -Cc adapter -F "name:type:description"',
        logger  => $logger,
    )) {
        $inventory->addEntry(
            section => 'CONTROLLERS',
            entry   => $controller
        );
    }
}

sub _getControllers {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @controllers;
    while (my $line = <$handle>) {
        next unless $line =~ /^(.+):(.+):(.+)/;
        push @controllers, {
            NAME         => $1,
            TYPE         => $2,
            MANUFACTURER => $3,
        };
    }
    close $handle;

    return @controllers;
}

1;
