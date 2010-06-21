package FusionInventory::Agent::Task::Inventory::OS::BSD::Archs::Sparc;

use strict;
use warnings;

sub isInventoryEnabled{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    $arch =~ /^sparc/;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
        $BiosVersion, $BiosDate);
    my ( $processort , $processorn , $processors );

    ### Get system serial with "sysctl kern.hostid"
    #
    # sysctl -n kern.hostid gives e.g. 0x807b65c on NetBSD
    # and 2155570635 on OpenBSD; we keep the hex form

    chomp ($SystemSerial = `sysctl -n kern.hostid`);
    if ( $SystemSerial =~ /^\d*$/ ) { # convert to NetBSD format
        $SystemSerial = sprintf ("0x%x",$SystemSerial);
    }
    $SystemSerial =~ s/^0x//; # remove 0x to make it appear as in the firmware

    ### Get system model and processor type in dmesg
    #
    # cannot use "sysctl hw.model" to get SystemModel
    # because it gives only the CPU on OpenBSD/sparc64
    #
    # Examples of dmesg output :
    #
    # I) SPARC
    # a) NetBSD
    # mainbus0 (root): SUNW,SPARCstation-20: hostid 72362bb1
    # cpu0 at mainbus0: TMS390Z50 v0 or TMS390Z55 @ 50 MHz, on-chip FPU
    # b) OpenBSD
    # mainbus0 (root): SUNW,SPARCstation-20
    # cpu0 at mainbus0: TMS390Z50 v0 or TMS390Z55 @ 50 MHz, on-chip FPU
    #
    # II) SPARC64
    # a) NetBSD
    # mainbus0 (root): SUNW,Ultra-1: hostid 807b65cb
    # cpu0 at mainbus0: SUNW,UltraSPARC @ 166.999 MHz, version 0 FPU
    # b) OpenBSD
    # mainbus0 (root): Sun Ultra 1 SBus (UltraSPARC 167MHz)
    # cpu0 at mainbus0: SUNW,UltraSPARC @ 166.999 MHz, version 0 FPU
    # c) FreeBSD
    # cpu0: Sun Microsystems UltraSparc-I Processor (167.00 MHz CPU)

    for (`dmesg`) {
        if (/^mainbus0 \(root\):\s*(.*)$/) { $SystemModel = $1; }
        if (/^cpu[^:]*:\s*(.*)$/i) { $processort = $1 unless $processort; }
    }
    $SystemModel || chomp ($SystemModel = `sysctl -n hw.model`); # for FreeBSD
    $SystemManufacturer = "SUN";
    # some cleanup
    $SystemModel =~ s/SUNW,//;
    $SystemModel =~ s/[:\(].*$//;
    $SystemModel =~ s/^\s*//;
    $SystemModel =~ s/\s*$//;
    $processort =~ s/SUNW,//;
    $processort =~ s/^\s*//;
    $processort =~ s/\s*$//;

    # number of procs with "sysctl hw.ncpu"
    chomp($processorn=`sysctl -n hw.ncpu`);
    # XXX quick and dirty _attempt_ to get proc speed
    if ( $processort =~ /(\d+)(\.\d+|)\s*mhz/i ) { # possible decimal point
        $processors = sprintf("%.0f", "$1$2"); # round number
    }

# Writing data
    $inventory->setBios ({
        SMANUFACTURER => $SystemManufacturer,
        SMODEL => $SystemModel,
        SSN => $SystemSerial,
        BMANUFACTURER => $BiosManufacturer,
        BVERSION => $BiosVersion,
        BDATE => $BiosDate,
    });

    $inventory->setHardware({
        PROCESSORT => $processort,
        PROCESSORN => $processorn,
        PROCESSORS => $processors
    });

}

1;
