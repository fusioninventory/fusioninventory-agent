package FusionInventory::Agent::Task::Inventory::Linux::SPARC::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{cpu};
    return -r '/proc/cpuinfo';
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
            NAME => $cpu->{cpu},
        };
    }

    return @cpus;
}



1;
