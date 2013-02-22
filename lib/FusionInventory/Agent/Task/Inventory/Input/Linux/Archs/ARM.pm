package FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::ARM;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return $Config{archname} =~ /^arm/ &&
           -r '/proc/cpuinfo';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc(
        logger => $logger, file => '/proc/cpuinfo')
    ) {
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
            ARCH  => 'ARM',
            TYPE  => $cpu->{processor}
        };
    }

    return @cpus;
}

1;
