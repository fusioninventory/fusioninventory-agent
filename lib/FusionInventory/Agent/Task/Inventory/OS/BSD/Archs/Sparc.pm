package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Sparc;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return $Config{archname} =~ /^sun4/;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    # sysctl infos

    # it gives only the CPU on OpenBSD/sparc64
    my $SystemModel = getFirstLine(command => 'sysctl -n hw.model');

    # example on NetBSD: 0x807b65c
    # example on OpenBSD: 2155570635
    my $SystemSerial = getFirstLine(command => 'sysctl -n kern.hostid');
    if ( $SystemSerial =~ /^\d*$/ ) { # convert to NetBSD format
        $SystemSerial = sprintf ("0x%x",$SystemSerial);
    }
    $SystemSerial =~ s/^0x//; # remove 0x to make it appear as in the firmware

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
    foreach (`dmesg`) {
        if (/^mainbus0 \(root\):\s*(.*)$/) { $SystemModel = $1; }
        if (/^cpu[^:]*:\s*(.*)$/i) { $processort = $1; }
    }

    $SystemModel =~ s/SUNW,//;
    $SystemModel =~ s/[:\(].*$//;
    $SystemModel =~ s/^\s*//;
    $SystemModel =~ s/\s*$//;

    $processort =~ s/SUNW,//;
    $processort =~ s/^\s*//;
    $processort =~ s/\s*$//;

    my $processors;
    # XXX quick and dirty _attempt_ to get proc speed
    if ( $processort =~ /(\d+)(\.\d+|)\s*mhz/i ) { # possible decimal point
        $processors = sprintf("%.0f", "$1$2"); # round number
    }

    $inventory->setBios({
        SMANUFACTURER => 'SUN',
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial,
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
