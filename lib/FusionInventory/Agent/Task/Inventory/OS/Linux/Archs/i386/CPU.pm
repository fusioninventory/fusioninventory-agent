package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

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

            if (
                $info->{'Max Speed'} &&
                $info->{'Max Speed'} =~ /(\d+)\s+(\S+)$/
            ) {
                my $value = $1;
                my $unit = $2;
                $cpu->{SPEED} = $unit eq 'GHz' ? $unit * 1000 : $unit;
            }

            $cpu->{SERIAL}       = $info->{'ID'};
            $cpu->{MANUFACTURER} = $info->{'Manufacturer'};
            $cpu->{THREAD}       = $info->{'Thread Count'} || 1;
            $cpu->{CORE}         = $info->{'Core Count'};

            push @cpu, $cpu;
        }
    }

    my @cpuProcs;
    my @cpuCoreCpts;
    if (!open my $handle, '<', '/proc/cpuinfo') {
        $logger->debug("Can't open /proc/cpuinfo: $ERRNO");
    } else {
        my $id=0;
        my $cpuInfo = {};
        my $cpuNbr = 0;
        my $hasPhysicalId;
        while (<$handle>) {
            if (/^physical\sid\s*:\s*(\d+)/i) {
                if ((!defined($cpuCoreCpts[$1]))||$cpuCoreCpts[$1]<$1+1) {
                    $cpuCoreCpts[$1] = $1+1;
                }
                $cpuNbr = $1;
                $hasPhysicalId = 1;
            } elsif (/^\s*(\S+.*\S+)\s*:\s*(.+)/i) {
                $cpuInfo->{$1} = $2;
            } elsif (/^\s*$/) {
                $cpuProcs[$cpuNbr]= $cpuInfo;
                $cpuInfo = {};
                $cpuNbr++ unless $hasPhysicalId;
            }
        }
        close $handle;
    }

    my $maxId = @cpu?@cpu-1:@cpuProcs-1;
    foreach my $id (0..$maxId) {
        if ($cpuProcs[$id]->{vendor_id}) {
            $cpuProcs[$id]->{vendor_id} =~ s/Genuine//;
            $cpuProcs[$id]->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $cpuProcs[$id]->{vendor_id} =~ s/CyrixInstead/Cyrix/;
            $cpuProcs[$id]->{vendor_id} =~ s/CentaurHauls/VIA/;

            $cpu[$id]->{MANUFACTURER} = $cpuProcs[$id]->{vendor_id};
        }
        $cpu[$id]->{NAME} = $cpuProcs[$id]->{'model name'};
        if (!$cpu[$id]->{CORE}) {
            $cpu[$id]->{CORE} = $cpuCoreCpts[$id];
        }
        if (!$cpu[$id]->{THREAD} && $cpuProcs[$id]->{'siblings'}) {
            $cpu[$id]->{THREAD} = $cpuProcs[$id]->{'siblings'};
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

1;
