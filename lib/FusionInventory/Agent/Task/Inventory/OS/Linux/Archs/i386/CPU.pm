package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return
        -r '/proc/cpuinfo' ||
        can_run('dmidecode');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my @cpus;

    if (can_run('dmidecode')) {
        my $infos = getInfosFromDmidecode(logger => $logger);

        if ($infos->{4}) {
            foreach my $info (@{$infos->{4}}) {
                push @cpus, {
                    SERIAL       => $info->{'ID'},
                    MANUFACTURER => $info->{'Manufacturer'},
                    CORE         => $info->{'Core Count'},
                    THREAD       => ($info->{'Thread Count'} || 1),
                    SPEED        => getCanonicalSpeed($info->{'Max Speed'})
                };
            }
        }
    }

    my ($proc_cpus, $proc_cores) = _getInfosFromProc($logger);

    foreach my $cpu (@cpus) {
        my $proc_cpu  = shift @$proc_cpus;
        my $proc_core = shift @$proc_cores;

        if ($proc_cpu->{vendor_id}) {
            $proc_cpu->{vendor_id} =~ s/Genuine//;
            $proc_cpu->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $proc_cpu->{vendor_id} =~ s/CyrixInstead/Cyrix/;
            $proc_cpu->{vendor_id} =~ s/CentaurHauls/VIA/;

            $cpu->{MANUFACTURER} = $proc_cpu->{vendor_id};
        }

        $cpu->{NAME} = $proc_cpu->{'model name'};

        if (!$cpu->{CORE}) {
            $cpu->{CORE} = $proc_core;
        }
        if (!$cpu->{THREAD} && $proc_cpu->{siblings}) {
            $cpu->{THREAD} = $proc_cpu->{siblings};
        }
        if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)} * $1;
        }

        $inventory->addCPU($cpu);
    }
}

sub _getInfosFromProc {
    my ($logger, $file) = @_;

    my $cpus = getCPUsFromProc(logger => $logger, file => $file);

    return unless $cpus;

    my ($procs, $cores);

    my $cpuNbr = 0;
    foreach my $cpu (@$cpus) {
        my $id = $cpu->{'physical id'};
        my $hasPhysicalId = 0;
        if (defined $id) {
            if (
                !defined($cores->[$id]) ||
                $cores->[$id] < $id + 1
            ) {
                $cores->[$id] = $id + 1;
            }
            $cpuNbr = $id;
            $hasPhysicalId = 1;
        }

        $procs->[$cpuNbr]= $cpu if keys %$cpu;
        $cpuNbr++ unless $hasPhysicalId;
    }

    return $procs, $cores;
}

1;
