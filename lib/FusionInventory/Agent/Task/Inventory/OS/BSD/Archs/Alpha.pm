package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Alpha;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return $Config{archname} =~ /^alpha/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # sysctl infos

    # example on *BSD: AlphaStation 255 4/232
    my $SystemModel = getFirstLine(command => 'sysctl -n hw.model');

    my $processorn = getFirstLine(command => 'sysctl -n hw.ncpu');

    # dmesg infos

    # NetBSD:
    # AlphaStation 255 4/232, 232MHz, s/n
    # cpu0 at mainbus0: ID 0 (primary), 21064A-2
    # OpenBSD:
    # AlphaStation 255 4/232, 232MHz
    # cpu0 at mainbus0: ID 0 (primary), 21064A-2 (pass 1.1)
    # FreeBSD:
    # AlphaStation 255 4/232, 232MHz
    # CPU: EV45 (21064A) major=6 minor=2

    my ($processort, $processors);
    foreach (`dmesg`) {
        if (/^cpu[^:]*:\s*(.*)$/i) { $processort = $1; }
        if (/$SystemModel,\s*(\S+)\s*MHz/) { $processors = $1; }
    }

    $inventory->setBios({
        SMANUFACTURER => 'DEC',
        SMODEL        => $SystemModel,
    });

    # don't deal with CPUs if information can be computed from dmidecode
    my $infos = getInfosFromDmidecode(logger => $logger);
    return if $infos->{4};

    for my $i (1 .. $processorn) {
         $inventory->addCPU({
             NAME  => $processort,
             SPEED => $processors,
         });
    }

}

1;
