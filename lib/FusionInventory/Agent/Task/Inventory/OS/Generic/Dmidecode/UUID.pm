package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::UUID;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run('dmidecode');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $uuid;

    $uuid = `dmidecode -s system-uuid`;
    chomp($uuid);
    $uuid =~ s/\s+$//g;

    $inventory->setHardware({
        UUID => $uuid,
    });

}

1;
