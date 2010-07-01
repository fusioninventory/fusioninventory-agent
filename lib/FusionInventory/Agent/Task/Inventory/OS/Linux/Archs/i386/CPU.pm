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

    my $arch = 'unknow';
    $arch = 'x86' if $Config{'archname'} =~ /^i\d86/;
    $arch = 'x86_64' if $Config{'archname'} =~ /^x86_64/;


    my $in;
    my $frequency;
    my $serial;
    my $manufacturer;
    my $thread;
    my $empty;
    foreach (`dmidecode`) {
        $in = 1 if /^\s*Processor Information/;

        if ($in) {
            $frequency = $1 if /^\s*Max Speed:\s*(\d+)\s*MHz/i;
            $frequency = $1*1000 if /^\s*Max Speed:\s*(\d+)\s*GHz/i;
            $serial = $1 if /^\s*ID:\s*(\S.+)/i;
            $manufacturer = $1 if /Manufacturer:\s*(\S.*)/;
            $thread = int($1) if /Thread Count:\s*(\S.*)/;
            $empty = 1 if /Status:\s*Unpopulated/i;

        }

        if ($in && /^\s*$/) {
            if (!$empty) {
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

            $in = undef;
            $frequency = undef;
            $serial = undef;
            $manufacturer = undef;
            $thread = undef;
            $empty = undef;

        }
    }

    my @cpuProcs;
    my @cpuCoreCpts;
    if (!open my $handle, '<', '/proc/cpuinfo') {
        $logger->debug("Can't open /proc/cpuinfo: $ERRNO");
    } else {
        my $id=0;
        my $cpuInfo = {};
        my $cpuNbr;
        while (<$handle>) {
            if (/^physical\sid\s*:\s*(\d+)/i) {
                $cpuCoreCpts[$1]++;
                $cpuNbr = $1;
            } elsif (/^\s*(\S+.*\S+)\s*:\s*(.+)/i) {
                $cpuInfo->{$1} = $2;
            } elsif (/^\s*$/) {
                $cpuProcs[$cpuNbr]= $cpuInfo;
                $cpuInfo = {};
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
