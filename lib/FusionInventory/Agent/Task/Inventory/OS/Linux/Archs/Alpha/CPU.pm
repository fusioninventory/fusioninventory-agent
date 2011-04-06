package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::Alpha::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled { 
    return -r '/proc/cpuinfo';
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    foreach my $cpu (_getCPUsFromProc($logger, '/proc/cpuinfo')) {
        $inventory->addCPU($cpu);
    }
}

sub _getCPUsFromProc {
    my ($logger, $file) = @_;

    my @cpus;
    foreach my $cpu (getCPUsFromProc(logger => $logger, file => $file)) {

        my $speed;
        if (
            $cpu->{'cycle frequency [hz]'} &&
            $cpu->{'cycle frequency [hz]'} =~ /(\d+)000000/
        ) {
            $speed = $1;
        }

        push @cpus, {
            ARCH   => 'Alpha',
            TYPE   => $cpu->{processor},
            SERIAL => $cpu->{'cpu serial number'},
            SPEED  => $speed
        };
    }

    return @cpus;
}

1;
