package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::i386;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

# Only run this module if dmidecode has not been found
our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode"];

sub isInventoryEnabled{
    return 
        $Config{'archname'} eq 'i386' || 
        $Config{'archname'} eq 'x86_64';
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    # system model
    my $SystemModel = getSingleLine(command => 'sysctl -n hw.model');

    # number of procs
    my $processorn = getSingleLine(command => 'sysctl -n hw.ncpu');

    # proc type
    my $processort = getSingleLine(command => 'sysctl -n hw.machine');

    # proc speed
    my $processors = getCanonicalSpeed(
        (split(/\s+/, $SystemModel))[-1]
    );

    $inventory->setBios ({
        SMODEL => $SystemModel,
    });

    $inventory->setHardware({
        PROCESSORT => $processort,
        PROCESSORN => $processorn,
        PROCESSORS => $processors
    });

}

1;
