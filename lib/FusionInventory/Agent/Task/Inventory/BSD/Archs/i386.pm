package FusionInventory::Agent::Task::Inventory::BSD::Archs::i386;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

# Only run this module if dmidecode has not been found
our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::Generic::Dmidecode"];

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
    my $bios = {
        SMODEL => getFirstLine(command => 'sysctl -n hw.model')
    };
    my $cpu = {
        NAME  => getFirstLine(command => 'sysctl -n hw.machine'),
        SPEED => (getCanonicalSpeed(split(/\s+/, $bios->{SMODEL})))[-1]
    };
    my $count = getFirstLine(command => 'sysctl -n hw.ncpu');

    $inventory->setBios($bios);

    # don't deal with CPUs if information can be computed from dmidecode
    my $infos = getInfosFromDmidecode(logger => $logger);
    return if $infos->{4};

    while ($count--) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

}

1;
