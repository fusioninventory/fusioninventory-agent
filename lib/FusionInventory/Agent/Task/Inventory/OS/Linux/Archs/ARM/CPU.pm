package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::ARM::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled { 
    return -r '/proc/cpuinfo';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc($logger)) {
        $inventory->addCPU($cpu);
    }
}

sub _getCPUsFromProc {
    my ($logger, $file) = @_;

    my @cpus;
    foreach my $cpu (getCPUsFromProc(logger => $logger, file => $file)) {

        push @cpus, {
            ARCH => 'ARM',
            TYPE => $cpu->{processor}
        };
    }

    return @cpus;
}

1;
