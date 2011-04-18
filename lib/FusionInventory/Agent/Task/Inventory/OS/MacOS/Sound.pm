package FusionInventory::Agent::Task::Inventory::OS::MacOS::Sound;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPAudioDataType');
    return unless ref $info eq 'HASH';

    # add sound cards
    foreach my $x (keys %$info){
        $inventory->addSound({
            section => 'SOUNDS',
            entry   => {
                NAME         => $x,
                MANUFACTURER => $x,
                DESCRIPTION  => $x,
            }
        });
    }
}

1;
