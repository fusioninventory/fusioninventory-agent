package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Alpha;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled{
    my $arch = getSingleLine(command => 'sysctl -n hw.machine');
    return $arch eq "alpha";
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    ### Get system model with "sysctl hw.model"
    #
    # example on *BSD
    # hw.model = AlphaStation 255 4/232

    my $SystemModel = getSingleLine(command => 'sysctl -n hw.model');
    my $SystemManufacturer = "DEC";

    ### Get processor type and speed in dmesg
    #
    # NetBSD:    AlphaStation 255 4/232, 232MHz, s/n
    #            cpu0 at mainbus0: ID 0 (primary), 21064A-2
    # OpenBSD:   AlphaStation 255 4/232, 232MHz
    #            cpu0 at mainbus0: ID 0 (primary), 21064A-2 (pass 1.1)
    # FreeBSD:   AlphaStation 255 4/232, 232MHz
    #            CPU: EV45 (21064A) major=6 minor=2

    my $processort;
    my $processors;
    for (`dmesg`) {
        if (/^cpu[^:]*:\s*(.*)$/i) { $processort = $1; }
        if (/$SystemModel,\s*(\S+)\s*MHz.*$/) { $processors = $1; }
    }


    # number of procs with sysctl (hw.ncpu)
    my $processorn = getSingleLine(command => 'sysctl -n hw.ncpu');

    # Writing data
    $inventory->setBios ({
        SMANUFACTURER => $SystemManufacturer,
        SMODEL => $SystemModel,
    });

    $inventory->setHardware({
        PROCESSORT => $processort,
        PROCESSORN => $processorn,
        PROCESSORS => $processors
    });

}

1;
