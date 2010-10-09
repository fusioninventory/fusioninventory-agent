package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

#processor       : 0
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#processor       : 1
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#timebase        : 181495202
#machine         : CHRP IBM,7029-6C3
#
#

sub isInventoryEnabled { can_read ("/proc/cpuinfo") };


sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $handle;
    if (!open $handle, '<', '/proc/cpuinfo') {
        warn "Can't open /proc/cpuinfo: $ERRNO";
        return
    }

    my @cpus;
    my $current;
    my $isIBM;

    while (<$handle>) {
        if (/^\s*$/) {
            if ($current->{NAME}) {
                push @cpus, $current;
            }
            $current = {};
            next;
        }

        $isIBM = 1 if /^machine\s*:.*IBM/;
        $current->{NAME} = $1 if /cpu\s+:\s+(\S.*)/;
        if (/clock\s+:\s+(\S.*)/) {
            $current->{SPEED} = $1;
            $current->{SPEED} =~ s/\.\d+/MHz/;
            $current->{SPEED} =~ s/MHz//;
            $current->{SPEED} =~ s/GHz//;
        }


        if (/^\s*$/) {
            if ($current->{NAME}) {
                push @cpus, $current;
            }
            $current = {};
        }
    }
    close $handle;

    foreach my $cpu (@cpus) {
        $cpu->{MANUFACTURER} = 'IBM' if $isIBM;
        $inventory->addCPU($cpu);
    }
}

1;
