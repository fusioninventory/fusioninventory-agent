package FusionInventory::Agent::Task::Inventory::OS::HPUX::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_run('ioscan');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    foreach my $scaned (qw/ioa ba/) {
        foreach my $line ( `ioscan -kFC $scaned| cut -d ':' -f 9,11,17,18` ) {
            next unless $line =~ /(\S+):(\S+):(\S+):(.+)/;
            $inventory->addSlot({
                DESCRIPTION => $2,
                DESIGNATION => "$3 $4",
                NAME        => $1,
                STATUS      => "OK",
            });
        }
    }
}

1;
