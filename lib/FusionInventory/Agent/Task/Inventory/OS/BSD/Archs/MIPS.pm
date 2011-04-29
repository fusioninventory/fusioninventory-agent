package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::MIPS;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return $Config{archname} =~ /^IP\d+/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # sysctl infos

    # example on NetBSD: SGI-IP22
    # example on OpenBSD: SGI-O2 (IP32)
    my $SystemModel = getFirstLine(command => 'sysctl -n hw.model');

    my $processorn = getFirstLine(command => 'sysctl -n hw.ncpu');

    # dmesg infos
    
    # I) Indy
    # NetBSD:
    # mainbus0 (root): SGI-IP22 [SGI, 6906e152], 1 processor
    # cpu0 at mainbus0: MIPS R4400 CPU (0x450) Rev. 5.0 with MIPS R4010 FPC Rev. 0.0
    # int0 at mainbus0 addr 0x1fbd9880: bus 75MHz, CPU 150MHz
    #
    # II) O2
    # NetBSD:
    # mainbus0 (root): SGI-IP32 [SGI, 8], 1 processor
    # cpu0 at mainbus0: MIPS R5000 CPU (0x2321) Rev. 2.1 with built-in FPU Rev. 1.0
    # OpenBSD:
    # mainbus0 (root)
    # cpu0 at mainbus0: MIPS R5000 CPU rev 2.1 180 MHz with R5000 based FPC rev 1.0
    # cpu0: cache L1-I 32KB D 32KB 2 way, L2 512KB direct

    my ($SystemSerial, $processort, $processors);
    foreach (`dmesg`) {
        if (/$SystemModel\s*\[\S*\s*(\S*)\]/) { $SystemSerial = $1; }
        if (/cpu0 at mainbus0:\s*(.*)$/) { $processort = $1; }
        if (/CPU\s*.*\D(\d+)\s*MHz/) { $processors = $1; }
    }

    $inventory->setBios({
        SMANUFACTURER => 'SGI',
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial,
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
