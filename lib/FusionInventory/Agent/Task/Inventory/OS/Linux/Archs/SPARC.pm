package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::SPARC;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return
        $Config{archname} =~ /^sparc/ &&
        -r '/proc/cpuinfo';
};

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc($logger, '/proc/cpuinfo')) {
        $inventory->addCPU($cpu);
    }

}

sub _getCPUsFromProc {
    my ($logger, $file) = @_;

    my $cpu = (getCPUsFromProc(logger => $logger, file => $file))[0];

    return unless $cpu && $cpu->{'ncpus probed'};

    my @cpus;
    foreach (1 .. $cpu->{'ncpus probed'}) {
        push @cpus, {
            ARCH => 'ARM',
            TYPE => $cpu->{cpu},
        };
    }

    return @cpus;
}



1;
