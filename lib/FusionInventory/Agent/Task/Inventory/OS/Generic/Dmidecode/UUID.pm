package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::UUID;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run('dmidecode');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $uuid;

    my $in;
    foreach (`dmidecode`) {
        if (/^Handle.*DMI type 1,/i) {
            $in = 1;
        } elsif ($in && /^Handle/i) {
            $in = 0;
            last;
        } elsif ($in) {
            if (/UUID:\s*(\S+)/i) {
                $uuid = $1;
                chomp($uuid);
                $uuid =~ s/\s+$//g;

                last;
            }
        }
    }

    $inventory->setHardware({
        UUID => $uuid,
    });

}

1;
