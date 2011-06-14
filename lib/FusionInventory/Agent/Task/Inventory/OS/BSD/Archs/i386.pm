package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::i386;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

# Only run this module if dmidecode has not been found
our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode"];

sub isEnabled{
    return 
        $Config{archname} eq 'i386' || 
        $Config{archname} eq 'x86_64';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # sysctl infos

    my $SystemModel = getFirstLine(command => 'sysctl -n hw.model');
    my $processorn = getFirstLine(command => 'sysctl -n hw.ncpu');
    my $processort = getFirstLine(command => 'sysctl -n hw.machine');
    my $processors = getCanonicalSpeed(
        (split(/\s+/, $SystemModel))[-1]
    );

    $inventory->setBios({
        SMODEL => $SystemModel,
    });

    # don't deal with CPUs if information can be computed from dmidecode
    my $infos = getInfosFromDmidecode(logger => $logger);
    return if $infos->{4};

    for my $i (1 .. $processorn) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => {
                NAME  => $processort,
                SPEED => $processors,
            }
        );
    }

}

1;
