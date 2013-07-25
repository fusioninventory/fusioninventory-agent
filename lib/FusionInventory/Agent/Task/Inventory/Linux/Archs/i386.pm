package FusionInventory::Agent::Task::Inventory::Linux::Archs::i386;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return
        $Config{archname} =~ /^(i\d86|x86_64)/ &&
        (
            -r '/proc/cpuinfo'
        );
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUs(logger => $logger)) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }
}

sub _getCPUs {
    my (%params) = @_;

    my @cpusFromDmidecode = getCpusFromDmidecode();

    my ($proc_cpu, $procList) = _getCPUsFromProc(%params);

    my $cpt = 0;
    my @baseCpuList = @cpusFromDmidecode ? @cpusFromDmidecode : @$procList;
    my @cpus;

    foreach my $cpu (@baseCpuList) {

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
            $cpu->{CORE} = $procList->[$cpt]{CORE};
        }
        if (!$cpu->{THREAD}) {
            $cpu->{THREAD} = $procList->[$cpt]{THREAD};
        }

        # Get directly informations from cpuinfo if not already processed
        # in dmidecode
        $cpu->{STEPPING} = $procList->[$cpt]{STEPPING}
            unless $cpu->{STEPPING} ;
        $cpu->{FAMILYNUMBER} = $procList->[$cpt]{FAMILYNUMBER}
            unless $cpu->{FAMILYNUMBER};
        $cpu->{MODEL} = $procList->[$cpt]{MODEL}
            unless $cpu->{MODEL};

        if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)} * $1;
        }

        push @cpus, $cpu;
        $cpt++;
    }

    return @cpus;
}

sub _getCPUsFromProc {
    my %params = (
        file => '/proc/cpuinfo',
        @_
    );
    my @cpus = getCPUsFromProc(%params);

    my $procs;
    my @cpuList;
    my %cpus;
    my $hasPhysicalId;

    foreach my $cpu (@cpus) {
        $procs = $cpu;
        my $id = $cpu->{'physical id'};
        $hasPhysicalId = 0;
        if (defined $id) {
            $cpus{$id}{STEPPING}     = $cpu->{'stepping'};
            $cpus{$id}{FAMILYNUMBER} = $cpu->{'cpu family'};
            $cpus{$id}{MODEL}        = $cpu->{'model'};
            $cpus{$id}{CORE}         = $cpu->{'cpu cores'};
            $cpus{$id}{THREAD}       = $cpu->{'siblings'} / ($cpu->{'cpu cores'} || 1);
            $hasPhysicalId = 1;
        }

        push @cpuList, {
            STEPPING     => $cpu->{'stepping'},
            FAMILYNUMBER => $cpu->{'cpu family'},
            MODEL        => $cpu->{'model'},
            CORE         => 1,
            THREAD       => 1
        } unless $hasPhysicalId;
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
