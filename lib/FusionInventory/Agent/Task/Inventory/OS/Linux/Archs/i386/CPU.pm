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

    open CPUINFO, "</proc/cpuinfo" or warn;
    foreach(<CPUINFO>) {
        if (/^processor\s*:/) {
            if ($current) {
                $inventory->addCPU($current);
            }

            $current = {
                MANUFACTURER => 'unknow'
            };

        }

#            $current->{SERIAL} = $1 TODO with dmidecode;
        if (/^vendor_id\s*:\s*(Authentic|Genuine|)(.+)/i) {
            $current->{MANUFACTURER} = $2;
            $current->{MANUFACTURER} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $current->{MANUFACTURER} =~ s/CyrixInstead/Cyrix/;
            $current->{MANUFACTURER} =~ s/CentaurHauls/VIA/;
        }
        $current->{SPEED} = $1 if /^cpu\sMHz\s*:\s*(\d+)(|\.\d+)$/i;
        $current->{TYPE} = $1 if /^model\sname\s*:\s*(.+)/i;

    }

    # The last one
    $inventory->addCPU($current);
}

1
