package FusionInventory::Agent::Task::Inventory::HPUX::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return
        canRun('uptime') &&
        canRun('uname');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $arch = getFirstLine(command => 'uname -m');
    my $uptime = _getUptime(command => 'uptime');
    $inventory->setHardware({
        DESCRIPTION => "$arch/$uptime"
    });
}

sub _getUptime {
    my ($days, $hours, $minutes) = getFirstMatch(
        pattern => qr/up \s (?:(\d+)\sdays\D+)? (\d{1,2}) : (\d{1,2})/x,
        @_
    );

    my $uptime = 0;
    $uptime += $days * 24 * 3600 if $days;
    $uptime += $hours * 3600;
    $uptime += $minutes * 60;

    return getFormatedGMTTime($uptime);
}

1;
