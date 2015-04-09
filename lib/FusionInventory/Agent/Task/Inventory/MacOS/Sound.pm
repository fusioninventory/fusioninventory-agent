package FusionInventory::Agent::Task::Inventory::MacOS::Sound;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{sound};
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $infos = getSystemProfilerInfos(type => 'SPAudioDataType', logger => $logger);
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
