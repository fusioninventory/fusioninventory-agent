package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::Alpha::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

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
            $cpu->{'cycle frequency [Hz]'} &&
            $cpu->{'cycle frequency [Hz]'} =~ /(\d+)000000/
        ) {
            $speed = $1;
        }
 
        $inventory->addCPU({
            ARCH   => 'Alpha',
            NAME   => $cpu->{Processor},
            SERIAL => $cpu->{'cpu serial number'},
            SPEED  => $speed
        });
    }
}

1;
