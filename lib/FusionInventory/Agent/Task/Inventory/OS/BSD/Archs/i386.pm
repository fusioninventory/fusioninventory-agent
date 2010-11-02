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
    my $SystemModel = getSingleLine(command => 'sysctl -n hw.machine');

    # number of procs
    my $processorn = getSingleLine(command => 'sysctl -n hw.ncpu');

    # proc type
    my $processort = getSingleLine(command => 'sysctl -n hw.model');

    # XXX quick and dirty _attempt_ to get proc speed through dmesg
    # FreeBSD
    # CPU: Intel(R) Core(TM) i5 CPU       M 430  @ 2.27GHz (2261.27-MHz K8-class CPU)
    my $processors;
    for (`dmesg`){
        next unless /^CPU:.* ([\d.]+)GHz/;
        $processors = $1;
        last
    }

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
