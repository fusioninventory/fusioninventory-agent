package FusionInventory::Agent::Task::Inventory::Linux::MIPS::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{cpu};
    return -r '/proc/cpuinfo';
}

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
    my @cpus;
    foreach my $cpu (getCPUsFromProc(@_)) {

       push @cpus, {
            ARCH => 'MIPS',
            NAME => $cpu->{'cpu model'},
        };
    }

    return @cpus;
}

1;
