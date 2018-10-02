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

    my $port;
    my $command = "ssh-keyscan";
    if (-e '/etc/ssh/sshd_config') {
        foreach my $line (getAllLines( file => '/etc/ssh/sshd_config' )) {
            next unless $line =~ /^Port\s+(\d+)/;
            $port = $1;
        }
    }
    $command .= " -p $port" if $port;

    # Use a 1 second timeout instead of default 5 seconds as this is still
    # large enough for loopback ssh pubkey scan.
    $command .= ' -T 1 127.0.0.1';
    my $ssh_key = getFirstMatch(
        command => $command,
        pattern => qr/^[^#]\S+\s(ssh.*)/,
        @_,
    );

    $inventory->setOperatingSystem({
        SSH_KEY => $ssh_key
    }) if $ssh_key;
}

1;
