package FusionInventory::Agent::Task::Inventory::Input::MacOS::Sound;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        canLoad("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPAudioDataType');
    return unless ref $info eq 'HASH';

    # add sound cards
    foreach my $x (keys %$info){
        $inventory->addEntry({
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
