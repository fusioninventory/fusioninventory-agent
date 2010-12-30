package FusionInventory::Agent::Task::Inventory::OS::HPUX::Controller;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('ioscan');
}

sub doInventory { 
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $name;
    my $interface;
    my $info;
    my $type;
    my @typeScaned=('ext_bus','fc','psi');
    my $scaned;

    foreach (@typeScaned ) {
        $scaned=$_;
        foreach ( `ioscan -kFC $scaned| cut -d ':' -f 9,11,17,18` ) {
            if ( /(\S+):(\S+):(\S+):(.+)/ ) {
                $name=$2;
                $interface=$3;
                $info=$4;
                $type=$1;
                $inventory->addController({
                    NAME          => $name,
                    MANUFACTURER  => "$interface $info",
                    TYPE          => $type,
                });
            }
        }
    }
}

1;
