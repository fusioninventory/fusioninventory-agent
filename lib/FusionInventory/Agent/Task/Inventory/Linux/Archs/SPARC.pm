package FusionInventory::Agent::Task::Inventory::Linux::Archs::SPARC;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return
        $Config{archname} =~ /^sparc/ &&
        -r '/proc/cpuinfo';
};

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc(
        logger => $logger, file => '/proc/cpuinfo'
    )) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

}

sub _getCPUsFromProc {
    my $cpu = (getCPUsFromProc(@_))[0];

    return unless $cpu && $cpu->{'ncpus probed'};

    my @cpus;
    foreach (1 .. $cpu->{'ncpus probed'}) {
        push @cpus, {
            ARCH => 'SPARC',
            TYPE => $cpu->{cpu},
        };
    }

    return @cpus;
}



1;
