package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::SPARC::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return -r '/proc/cpuinfo';
};

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cpus = getCPUsFromProc($params->{logger});

    return unless $cpus;

    my $cpu = $cpus->[0];

    if ($cpu->{'ncpus probed'}) {
        foreach (1 .. $cpu->{'ncpus probed'}) {
            $inventory->addCPU({
                ARCH => 'ARM'
                TYPE => $cpu->{cpu},
            });
        }
    }
}

1;
