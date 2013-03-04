package FusionInventory::Agent::Task::Inventory::Linux::Uptime;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    return -r '/proc/uptime';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $uptime = _getUptime(file => '/proc/uptime');
    $inventory->setOperatingSystem({
        BOOT_TIME => $uptime
    });
}

sub _getUptime {
    my $uptime = getFirstMatch(
        pattern => qr/^(\S+)/,
        @_
    );
    return unless $uptime;

    return getFormatedLocalTime(int(time - $uptime));
}

1;
