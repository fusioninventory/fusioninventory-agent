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

    # sysctl infos

    my $SystemModel = getSingleLine(command => 'sysctl -n hw.model');
    my $processorn = getSingleLine(command => 'sysctl -n hw.ncpu');
    my $processort = getSingleLine(command => 'sysctl -n hw.machine');
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
