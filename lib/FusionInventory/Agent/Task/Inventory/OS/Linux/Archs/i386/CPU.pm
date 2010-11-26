package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

sub isInventoryEnabled { can_read("/proc/cpuinfo") || can_run('dmidecode') }

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
    my $core;
    my $name;
    my $id;
    foreach (`dmidecode`) {
        $in = 1 if /^\s*Processor Information/;

        if ($in) {
            $frequency = $1 if /^\s*Max Speed:\s*(\d+)\s*MHz/i;
            $frequency = $1*1000 if /^\s*Max Speed:\s*(\d+)\s*GHz/i;
            $serial = $1 if /^\s*Serial\s*Number:\s*(\S.+)/i;
            $id = $1 if /^\s*ID:\s*(\S.+)/i;
            $manufacturer = $1 if /Manufacturer:\s*(\S.*)/;
            $thread = int($1) if /Thread Count:\s*(\S.*)/;
            $core = int($1) if /Core Count:\s*(\S.*)/;
            $empty = 1 if /Status:\s*Unpopulated/i;
            $name = $1 if /^\s*Version:\s*(\S.+)/i;

        }

        if ($in && (/^Handle\s0x/i || /^\s*$/)) {
            if (!$empty) {
                $serial =~ s/\s//g;
                $thread = 1 unless $thread;

                push @cpu, {
                    SPEED => $frequency,
                    MANUFACTURER => $manufacturer,
                    SERIAL => $serial,
# Thread per core according to my understanding of
# http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/25481.pdf
                    THREAD => $thread,
                    CORE => $core,
                    NAME => $name,
                    ID => $id,
                }
            }

            $in = undef;
            $frequency = undef;
            $serial = undef;
            $manufacturer = undef;
            $thread = undef;
            $empty = undef;
            $empty = undef;
            $core = undef;
            $name = undef;

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
        # The /proc/cpuinfo file doesn't end with an empty line
        $cpuProcs[$cpuNbr]= $cpuInfo if keys %$cpuInfo;
    }

    my $maxId = @cpu?@cpu-1:@cpuProcs-1;
    foreach my $id (0..$maxId) {
        my $cpuProc = $cpuProcs[$id] || $cpuProcs[0];

        if ($cpuProc->{vendor_id}) {
            $cpu[$id]->{MANUFACTURER} = $cpuProc->{vendor_id};
        }
        if ($cpu[$id]->{MANUFACTURER}) {
            $cpu[$id]->{MANUFACTURER} =~ s/Genuine//;
            $cpu[$id]->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $cpu[$id]->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
            $cpu[$id]->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
        }
        if ($cpuProc->{'model name'}) {
            $cpu[$id]->{NAME} = $cpuProc->{'model name'};
        }
        if (!$cpu[$id]->{CORE}) {
            $cpu[$id]->{CORE} = $cpuCoreCpts[$id] || 1;
        }
        if (!$cpu[$id]->{THREAD} && $cpuProc->{'siblings'}) {
            $cpu[$id]->{THREAD} = $cpuProc->{'siblings'};
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
