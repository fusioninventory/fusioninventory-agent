package FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run('ioscan');
}

sub doInventory { 
    my $params = shift;
    my $inventory = $params->{inventory};

    my $name;
    my $interface;
    my $info;
    my $type;
    my @typeScaned=('ioa','ba');
    my $scaned;

    for (@typeScaned ) {
        $scaned=$_;
        for ( `ioscan -kFC $scaned| cut -d ':' -f 9,11,17,18` ) {
            if ( /(\S+):(\S+):(\S+):(.+)/ ) {
                $name=$2;
                $interface=$3;
                $info=$4;
                $type=$1;
                $inventory->addSlot({
                    DESCRIPTION =>  "$name",
                    DESIGNATION =>  "$interface $info",
                    NAME            =>  "$type",
                    STATUS          =>  "OK",
                });
            }
        }
    }
}

1;
