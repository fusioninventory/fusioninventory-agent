package FusionInventory::Agent::Task::Inventory::Input::Linux::Uptime;

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

    my $arch = getFirstLine(command => 'uname -m');
    my $uptime = _getUptime(file => '/proc/uptime');
    $inventory->setHardware({
        DESCRIPTION => "$arch/$uptime"
    });
}

sub _getUptime {
    my $uptime = getFirstMatch(
        pattern => qr/^(\S+)/,
        @_
    );
    return unless $uptime;

    return getFormatedGmTime($uptime);
}

1;
