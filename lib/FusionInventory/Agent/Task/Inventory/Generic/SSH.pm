package FusionInventory::Agent::Task::Inventory::Generic::SSH;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('ssh-keyscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Use a 1 second timeout instead of default 5 seconds as this is still
    # large enough for loopback ssh pubkey scan.
    my $ssh_key = getFirstMatch(
        command => 'ssh-keyscan -T 1 127.0.0.1',
        pattern => qr/^[^#]\S+\s(ssh.*)/,
        @_,
    );

    $inventory->setOperatingSystem({
        SSH_KEY => $ssh_key
    }) if $ssh_key;
}

1;
