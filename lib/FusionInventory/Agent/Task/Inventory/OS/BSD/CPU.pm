package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {1}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $speed;
    my $hwModel = getFirstLine(command => 'sysctl -n hw.model');
    if ($hwModel =~ /([\.\d]+)GHz/) {
        $speed = $1 * 1000;
    }

    my $cpus = getCpusFromDmidecode();
    foreach my $cpu (@$cpus) {
        $cpu->{SPEED} = $speed;
        $inventory->addCPU($cpu);
    }
}

1;
