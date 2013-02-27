package FusionInventory::Agent::Task::Inventory::Generic::SSH;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('ssh-keyscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $ssh_key = getFirstMatch(
        command => 'ssh-keyscan 127.0.0.1',
        pattern => qr/^[^#]\S+\s(ssh.*)/,
        @_,
    );

    $inventory->setOperatingSystem({
        SSH_KEY => $ssh_key
    });
}

1;
