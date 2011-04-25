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

    foreach my $type (qw/ext_bus fc psi/) {
        foreach (`ioscan -kFC $type| cut -d ':' -f 9,11,17,18`) {
            next unless /(\S+):(\S+):(\S+):(.+)/;
            $inventory->addEntry(
                section => 'CONTROLLERS',
                entry   => {
                    NAME         => $2,
                    MANUFACTURER => "$3 $4",
                    TYPE         => $1,
                }
            );
        }
    }
}

1;
