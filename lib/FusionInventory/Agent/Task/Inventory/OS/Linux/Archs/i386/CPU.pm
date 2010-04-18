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

    chomp(my $frequency = `dmidecode -s processor-frequency`);
    $frequency =~ s/\ *MHz//i;
    if ($frequency =~ s/\ *GHz//i) {
        $frequency *= 1000;
    }

    my @cpu;
    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {
        if (/^processor\s*:/) {
            if ($current) {
                push @cpu, $current;
            }

            $current = {
                MANUFACTURER => 'unknown'
            };

        }

#            $current->{SERIAL} = $1 TODO with dmidecode;
        if (/^vendor_id\s*:\s*(Authentic|Genuine|)(.+)/i) {
            $current->{MANUFACTURER} = $2;
            $current->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $current->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
            $current->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
        }

        if ($frequency) {
            $current->{SPEED} = $frequency;

        } elsif(/^cpu\sMHz\s*:\s*(\d+)(|\.\d+)$/i) {
            $current->{SPEED} = $1;
        }
        $current->{NAME} = $1 if /^model\sname\s*:\s*(.+)/i;

    }

    foreach (@cpu) {
        $inventory->addCPU($_);
    }
}

1
