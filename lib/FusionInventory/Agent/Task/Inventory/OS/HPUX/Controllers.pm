package FusionInventory::Agent::Task::Inventory::OS::HPUX::Controllers;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('ioscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $type (qw/ext_bus fc psi/) {
        foreach my $controller (_getControllers(
            command => "ioscan -kFC $type| cut -d ':' -f 9,11,17,18",
            logger  => $logger
        )) {
            $inventory->addEntry(
                section => 'CONTROLLERS',
                entry   => $controller
            );
        }
    }
}

sub _getControllers {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @controllers;
    while (my $line = <$handle>) {
        next unless $line =~ /(\S+):(\S+):(\S+):(.+)/;
        push @controllers, {
            NAME         => $2,
            MANUFACTURER => "$3 $4",
            TYPE         => $1,
        };
    }
    close $handle;

    return @controllers;
}

1;
