package FusionInventory::Agent::Task::Inventory::Input::BSD::Archs::SPARC;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return $Config{archname} =~ /^sun4/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $bios = {
        SMANUFACTURER => 'SUN',
    };

    # sysctl infos

    # it gives only the CPU on OpenBSD/sparc64
    $bios->{SMODEL} = getFirstLine(command => 'sysctl -n hw.model');

    # example on NetBSD: 0x807b65c
    # example on OpenBSD: 2155570635
    $bios->{SSN} = getFirstLine(command => 'sysctl -n kern.hostid');
    # force hexadecimal, but remove 0x to make it appear as in the firmware
    $bios->{SSN} = dec2hex($bios->{SSN});
    $bios->{SSN} =~ s/^0x//;

    my $processorn = getFirstLine(command => 'sysctl -n hw.ncpu');

    # dmesg infos

    # I) SPARC
    # NetBSD:
    # mainbus0 (root): SUNW,SPARCstation-20: hostid 72362bb1
    # cpu0 at mainbus0: TMS390Z50 v0 or TMS390Z55 @ 50 MHz, on-chip FPU
    # OpenBSD:
    # mainbus0 (root): SUNW,SPARCstation-20
    # cpu0 at mainbus0: TMS390Z50 v0 or TMS390Z55 @ 50 MHz, on-chip FPU
    #
    # II) SPARC64
    # NetBSD:
    # mainbus0 (root): SUNW,Ultra-1: hostid 807b65cb
    # cpu0 at mainbus0: SUNW,UltraSPARC @ 166.999 MHz, version 0 FPU
    # OpenBSD:
    # mainbus0 (root): Sun Ultra 1 SBus (UltraSPARC 167MHz)
    # cpu0 at mainbus0: SUNW,UltraSPARC @ 166.999 MHz, version 0 FPU
    # FreeBSD:
    # cpu0: Sun Microsystems UltraSparc-I Processor (167.00 MHz CPU)

    my $processort;
    foreach my $line (getAllLines(command => 'dmesg')) {
        if ($line=~ /^mainbus0 \(root\):\s*(.*)$/) { $bios->{SMODEL} = $1; }
        if ($line =~ /^cpu[^:]*:\s*(.*)$/i)        { $processort = $1; }
    }

    $bios->{SMODEL} =~ s/SUNW,//;
    $bios->{SMODEL} =~ s/[:\(].*$//;
    $bios->{SMODEL} =~ s/^\s*//;
    $bios->{SMODEL} =~ s/\s*$//;

    $processort =~ s/SUNW,//;
    $processort =~ s/^\s*//;
    $processort =~ s/\s*$//;

    my $processors;
    # XXX quick and dirty _attempt_ to get proc speed
    if ( $processort =~ /(\d+)(\.\d+|)\s*mhz/i ) { # possible decimal point
        $processors = sprintf("%.0f", "$1$2"); # round number
    }

    $inventory->setBios($bios);

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
