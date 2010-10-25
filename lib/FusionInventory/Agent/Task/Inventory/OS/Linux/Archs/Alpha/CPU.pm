package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::Alpha::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { can_read("/proc/cpuinfo") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $handle;
    if (!open $handle, '<', '/proc/cpuinfo') {
        warn "Can't open /proc/cpuinfo: $ERRNO";
        return;
    }

    my @cpu;
    my $current;

    while (<$handle>) {
        print;
        if (/^cpu\s*:/) {
            if ($current) {
                $inventory->addCPU($current);
            }

            $current = {
                ARCH => 'Alpha',
            };
        } else {
            $current->{SERIAL} = $1 if /^cpu serial number\s+:\s+(\S.*)/;
            $current->{SPEED} = $1 if /cycle frequency \[Hz\]\s+:\s+(\d+)000000/;
            $current->{NAME} = $1 if /platform string\s+:\s+(\S.*)/;
        }
    }
    close $handle;

    # The last one
    $inventory->addCPU($current);
}

1;
