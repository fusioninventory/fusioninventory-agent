package FusionInventory::Agent::Task::Inventory::OS::Linux::Arachs::Alpha::CPU;

use strict;

sub isInventoryEnabled { can_read("/proc/cpuinfo") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @cpu;
    my $current;
    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {
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
            $current->{TYPE} = $1 if /platform string\s+:\s+(\S.*)/;

        }
    }

    # The last one
    $inventory->addCPU($current);
}

1
