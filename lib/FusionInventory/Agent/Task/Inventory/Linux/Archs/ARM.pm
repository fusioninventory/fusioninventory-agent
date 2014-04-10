package FusionInventory::Agent::Task::Inventory::Linux::Archs::ARM;

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

    # https://github.com/joyent/libuv/issues/812
    foreach my $cpu (getCPUsFromProc(@_)) {
        push @cpus, {
            ARCH  => 'ARM',
            NAME  => $cpu->{'model name'} || $cpu->{processor}
        };
    }

    return @cpus;
}

1;
