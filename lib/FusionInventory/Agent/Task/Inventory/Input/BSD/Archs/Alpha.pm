package FusionInventory::Agent::Task::Inventory::Input::BSD::Archs::Alpha;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isEnabled {
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
    foreach my $line (getAllLines(command => 'dmesg')) {
        if ($line =~ /$SystemModel,\s*(\S+)\s*MHz/) { $processors = $1; }
        if ($line =~ /^cpu[^:]*:\s*(.*)$/i)         { $processort = $1; }
    }

    $inventory->setBios({
        SMANUFACTURER => 'DEC',
        SMODEL        => $SystemModel,
    });

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
