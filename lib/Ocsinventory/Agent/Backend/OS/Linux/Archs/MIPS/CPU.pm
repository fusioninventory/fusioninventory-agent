package Ocsinventory::Agent::Backend::OS::Linux::Archs::MIPS::CPU;
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
        if (/^system type\s+:\s*:/) {

            if ($current) {
                $inventory->addCPU($current);
            }

            $current = {
                ARCH => 'MIPS',
            };

        }

        $current->{TYPE} = $1 if /cpu model\s+:\s+(\S.*)/;

    }

    # The last one
    $inventory->addCPU($current);
}

1
