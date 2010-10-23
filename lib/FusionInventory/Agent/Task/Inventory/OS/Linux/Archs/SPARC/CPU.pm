package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::SPARC::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { can_read ("/proc/cpuinfo") };

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @cpu;
    my $current = { ARCH => 'ARM' };
    my $ncpus = 1;

    if (!open my $handle, '<', '/proc/cpuinfo') {
        warn "Can't open /proc/cpuinfo: $ERRNO";
    } else {
        while (<$handle>) {
            $current->{NAME} = $1 if /cpu\s+:\s+(\S.*)/;
            $ncpus = $1 if /ncpus probed\s+:\s+(\d+)/
        }
        close $handle;
    }

    foreach (1..$ncpus) {
        $inventory->addCPU($current);
    }
}

1;
