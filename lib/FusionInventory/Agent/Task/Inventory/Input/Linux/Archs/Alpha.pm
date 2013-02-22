package FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::Alpha;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return $Config{archname} =~ /^alpha/ &&
           -r '/proc/cpuinfo';
};

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
