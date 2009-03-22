package Ocsinventory::Agent::Backend::OS::Linux::Archs::ARM::CPU;

use strict;

sub check { can_read("/proc/cpuinfo") }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @cpu;
    my $current;
    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {
        print;
        if (/^Processor\s+:\s*:/) {

            if ($current) {
                $inventory->addCPU($current);
            }

            $current = {
                ARCH => 'ARM',
            };

        }

        $current->{TYPE} = $1 if /Processor\s+:\s+(\S.*)/;

    }

    # The last one
    $inventory->addCPU($current);
}

1
