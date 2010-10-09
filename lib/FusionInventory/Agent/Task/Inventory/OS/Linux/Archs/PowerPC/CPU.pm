package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

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

sub isInventoryEnabled {
    return -r '/proc/cpuinfo';
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cpus = getCPUsFromProc($params->{logger});

    return unless $cpus;

    foreach my $cpu (@$cpus) {
        my $speed;
        if (
            $cpu->{'clock'} &&
            $cpu->{'clock'} =~ /(\d+)/
        ) {
            $speed = $1;
        }

        my $manufacturer;
        if ($cpu->{'machine'} &&
            $cpu->{'machine'} =~ /IBM/
        ) {
            $manufacturer = 'IBM';
        }

        $inventory->addCPU({
            NAME         => $cpu->{cpu},
            MANUFACTURER => $manufacturer,
            SPEED        => $speed
        });
    }
}

1;
