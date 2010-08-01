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

    my @cpu;

    my $infos = getInfosFromDmidecode();

    if ($infos->{4}) {
        foreach my $info (@{$infos->{4}}) {
            my $cpu;

            $cpu->{SERIAL}       = $info->{'ID'};
            $cpu->{MANUFACTURER} = $info->{'Manufacturer'};
            $cpu->{THREAD}       = $info->{'Thread Count'} || 1;
            $cpu->{CORE}         = $info->{'Core Count'};
            $cpu->{SPEED}        = getCanonicalSpeed($info->{'Max Speed'});

            push @cpu, $cpu;
        }
    }

    my ($cpuProcs, $cpuCoreCpts) = getInfosFromProc($logger);

    my $maxId = @cpu?@cpu-1:@$cpuProcs-1;
    foreach my $id (0..$maxId) {
        if ($cpuProcs->[$id]->{vendor_id}) {
            $cpuProcs->[$id]->{vendor_id} =~ s/Genuine//;
            $cpuProcs->[$id]->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $cpuProcs->[$id]->{vendor_id} =~ s/CyrixInstead/Cyrix/;
            $cpuProcs->[$id]->{vendor_id} =~ s/CentaurHauls/VIA/;

            $cpu[$id]->{MANUFACTURER} = $cpuProcs->[$id]->{vendor_id};
        }
        $cpu[$id]->{NAME} = $cpuProcs->[$id]->{'model name'};
        if (!$cpu[$id]->{CORE}) {
            $cpu[$id]->{CORE} = $cpuCoreCpts->[$id];
        }
        if (!$cpu[$id]->{THREAD} && $cpuProcs->[$id]->{'siblings'}) {
            $cpu[$id]->{THREAD} = $cpuProcs->[$id]->{'siblings'};
        }
        if ($cpu[$id]->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu[$id]->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)}*$1;
        }

        $inventory->addCPU($cpu[$id]);
    }
}

sub getInfosFromProc {
    my ($logger, $file) = @_;

    my $cpus = getCPUsFromProc($logger, $file);

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

        $procs->[$cpuNbr]= $cpu;
        $cpuNbr++ unless $hasPhysicalId;
    }

    return $procs, $cores;
}

1;
