package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('dmidecode');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $speed;
    my $hwModel = getFirstLine(command => 'sysctl -n hw.model');
    if ($hwModel =~ /([\.\d]+)GHz/) {
        $speed = $1 * 1000;
    }

    foreach my $cpu (getCpusFromDmidecode()) {
        $cpu->{SPEED} = $speed;
        $inventory->addCPU($cpu);
    }

}

1;
