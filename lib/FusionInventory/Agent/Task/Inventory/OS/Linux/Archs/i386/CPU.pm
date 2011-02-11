package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return
        -r '/proc/cpuinfo' ||
        can_run('dmidecode');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $cpusFromDmidecode = getCpusFromDmidecode();

    my ($proc_cpus, $proc_cores, $proc_threads) = _getCPUsFromProc($logger, '/proc/cpuinfo');

    foreach my $cpu (@$cpusFromDmidecode) {
        my $proc_cpu  = shift @$proc_cpus;
        my $proc_core = shift @$proc_cores;

        if ($proc_cpu->{vendor_id}) {
            $proc_cpu->{vendor_id} =~ s/Genuine//;
            $proc_cpu->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $proc_cpu->{vendor_id} =~ s/CyrixInstead/Cyrix/;
            $proc_cpu->{vendor_id} =~ s/CentaurHauls/VIA/;
            $proc_cpu->{vendor_id} =~ s/AuthenticAMD/AMD/;

            $cpu->{MANUFACTURER} = $proc_cpu->{vendor_id};
        }

        if ($proc_cpu->{'model name'}) {
            $cpu->{NAME} = $proc_cpu->{'model name'};
        }

        if (!$cpu->{CORE}) {
            $cpu->{CORE} = $proc_core;
        }
        if (!$cpu->{THREAD} && $proc_threads) {
            $cpu->{THREAD} = $proc_threads
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

sub _getCPUsFromProc {
    my ($logger, $file) = @_;

    my @cpus = getCPUsFromProc(logger => $logger, file => $file);

    my ($procs, $cpuNbr, $cores, $threads);

    my @cpuList;

    my %cpus;
    my $hasPhysicalId;
    foreach my $cpu (@cpus) {
        $procs = $cpu;
        my $id = $cpu->{'physical id'};
        $hasPhysicalId = 0;
        if (defined $id) {
            $cpus{$id}{core} = $cpu->{'cpu cores'};
            $cpus{$id}{thread} = $cpu->{'siblings'} / ($cpu->{'cpu cores'} || 1);
            $hasPhysicalId = 1;
        }

        push @cpuList, { core => 1, thread => 1 } unless $hasPhysicalId;
    }
    if (!$cpuNbr) {
        $cpuNbr = keys %cpus;
    }

# physical id may not start at 0!
    if ($hasPhysicalId) {
        foreach (keys %cpus) {
            push @cpuList, $cpus{$_};
        }
    }
    return $procs, \@cpuList;
}

1;
