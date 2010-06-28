package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

sub isInventoryEnabled { can_read("/proc/cpuinfo") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my @cpu;
    my $current;

    my $arch = 'unknow';
    $arch = 'x86' if $Config{'archname'} =~ /^i\d86/;
    $arch = 'x86_64' if $Config{'archname'} =~ /^x86_64/;


    my $in;
    my $frequency;
    my $serial;
    my $manufacturer;
    my $thread;
    foreach (`dmidecode`) {
        $in = 1 if /^\s*Processor Information/;

        if ($in) {
            $frequency = $1 if /^\s*Max Speed:\s*(\d+)\s*MHz/i;
            $frequency = $1*1000 if /^\s*Max Speed:\s*(\d+)\s*GHz/i;
            $serial = $1 if /^\s*ID:\s*(\S.+)/i;
            $manufacturer = $1 if /Manufacturer:\s*(\S.*)/;
            $thread = int($1) if /Thread Count:\s*(\S.*)/;
        }

        if ($in && /^\s*$/) {
            $in = 0;
            $serial =~ s/\s//g;
            $thread = 1 unless $thread;
            push @cpu, {
                SPEED => $frequency,
                MANUFACTURER => 'unknown',
                SERIAL => $serial,
# Thread per core according to my understanding of
# http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/25481.pdf
                THREAD => $thread
            }
        }
    }

    my @cpuProcs;
    my @cpuCoreCpts;
    if (!open my $handle, '<', '/proc/cpuinfo') {
        $logger->debug("Can't open /proc/cpuinfo: $ERRNO");
    } else {
        my $id=0;
        my %current;
        my $cpuNumber = 0;
        my $lastPhysicalId=0;
        while (<$handle>) {
            if (/^physical\sid\s*:\s*(\d+)/i) {
                if ($lastPhysicalId!=$1) {
                    $lastPhysicalId=$1;
                    $cpuNumber++;
                    $cpuCoreCpts[$cpuNumber]++;
                } else {
                    $cpuCoreCpts[$cpuNumber]++;
                }
            } elsif (/^\s*(\S+.*\S+)\s*:\s*(.+)/i) {
                $cpuProcs[$cpuNumber]->{$1} = $2;
            }
        }
        close $handle;
    }

    foreach my $id (0..(@cpu-1)) {
        $cpuProcs[$id]->{vendor_id} =~ s/Genuine//;
        $cpuProcs[$id]->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
        $cpuProcs[$id]->{vendor_id} =~ s/CyrixInstead/Cyrix/;
        $cpuProcs[$id]->{vendor_id} =~ s/CentaurHauls/VIA/;

        $cpu[$id]->{MANUFACTURER} = $cpuProcs[$id]->{vendor_id};
        $cpu[$id]->{NAME} = $cpuProcs[$id]->{'model name'};
        $cpu[$id]->{CORE} = $cpuCoreCpts[$id];

        $inventory->addCPU($cpu[$id]);
    }
}

1;
