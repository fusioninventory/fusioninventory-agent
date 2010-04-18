package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;

use strict;

use Config;

sub isInventoryEnabled { can_read("/proc/cpuinfo") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

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
                THREAD => $thread
            }
        }
    }

    my %current;
    my $id=0;
    my $lastPhysicalId;
    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {
        if (/^$/) {
            $current = {};
            if (!$id) {
                $lastPhysicalId=$current{'physical id'};
            } elsif ($lastPhysicalId != $current{'physical id'}) {
                $id++;
            }

            if ($current{vendor_id}) {
                $cpu[$id]->{MANUFACTURER} = $current{vendor_id};
                $cpu[$id]->{MANUFACTURER} =~ s/Genuine//;
                $cpu[$id]->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
                $cpu[$id]->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
                $cpu[$id]->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
            }
            $cpu[$id]->{NAME} = $current{'model name'};
            $cpu[$id]->{CORE}++;


        };
        $current{lc($1)} = $2 if /^\s*(\S+.*\S+)\s*:\s*(.+)/i;
    }

    foreach (@cpu) {
        $inventory->addCPU($_);
    }
}

1
