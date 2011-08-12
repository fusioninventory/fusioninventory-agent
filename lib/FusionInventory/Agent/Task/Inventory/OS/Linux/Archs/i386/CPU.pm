package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { can_read("/proc/cpuinfo") || can_run('dmidecode') }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my @cpu;

    my $arch = 'unknow';
    $arch = 'x86' if $Config{'archname'} =~ /^i\d86/;
    $arch = 'x86_64' if $Config{'archname'} =~ /^x86_64/;

    my $cpus = getCpusFromDmidecode();

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
                if ($hasPhysicalId || !defined($cpuCoreCpts[$1])) {
                    $cpuCoreCpts[$1]++;
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
            $cpus->[$id]->{MANUFACTURER} = $cpuProc->{vendor_id};
        }
        if ($cpus->[$id]->{MANUFACTURER}) {
            $cpus->[$id]->{MANUFACTURER} =~ s/Genuine//;
            $cpus->[$id]->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $cpus->[$id]->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
            $cpus->[$id]->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
            $cpus->[$id]->{MANUFACTURER} =~ s/AuthenticAMD/AMD/;
        }
        if ($cpuProc->{'model name'}) {
            $cpus->[$id]->{NAME} = $cpuProc->{'model name'};
        }
        if (!$cpus->[$id]->{CORE}) {
            $cpus->[$id]->{CORE} = $cpuCoreCpts[$id] || 1;
        }
        if (!$cpus->[$id]->{THREAD} && $cpuProc->{'siblings'}) {
            $cpus->[$id]->{THREAD} = $cpuProc->{'siblings'};
        }
        if ($cpus->[$id]->{NAME} && $cpus->[$id]->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpus->[$id]->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)}*$1;
        }

        $inventory->addCPU($cpus->[$id]);
    }
}

1;
