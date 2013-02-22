package FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::m68k;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return
        $Config{archname} =~ /^m68k/ &&
        -r '/proc/cpuinfo';
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
            ARCH  => 'm68k',
            TYPE  => $cpu->{'cpu'},
            SPEED => $cpu->{'clocking'}
        };
    }

    return @cpus;
}

1;
