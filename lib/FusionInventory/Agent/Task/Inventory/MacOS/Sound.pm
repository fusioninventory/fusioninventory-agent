package FusionInventory::Agent::Task::Inventory::MacOS::Sound;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $infos = getSystemProfilerInfos();
    my $info = $infos->{'Audio (Built In)'};

    foreach my $sound (keys %$info){
        $inventory->addEntry(
            section => 'SOUNDS',
            entry   => {
                NAME         => $sound,
                MANUFACTURER => $sound,
                DESCRIPTION  => $sound,
            }
        );
    }
}

1;
