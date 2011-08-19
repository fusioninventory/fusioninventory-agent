package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use FusionInventory::Agent::Tools;

use strict;
use warnings;

sub isInventoryEnabled {
    return unless -r "/dev/mem";

    `which dmidecode 2>&1`;
    return if ($? >> 8)!=0;
    `dmidecode 2>&1`;
    return if ($? >> 8)!=0;
    1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cpus = getCpusFromDmidecode();
    foreach my $cpu (@$cpus) {
        chomp(my $hwModel = `sysctl -n hw.model`);

        my $frequency;
        if ($hwModel =~ /([\.\d]+)GHz/) {
            $frequency = $1 * 1000;
        }
        $cpu->{SPEED} = $frequency;

        $inventory->addCPU($cpu);
    }

}
1;
