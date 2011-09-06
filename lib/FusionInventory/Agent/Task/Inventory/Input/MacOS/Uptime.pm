package FusionInventory::Agent::Task::Inventory::Input::MacOS::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return getFirstLine(command => 'sysctl -n kern.boottime');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $arch = getFirstLine(command => 'uname -m');
    my $uptime = _getUptime(command => 'sysctl -n kern.boottime');
    $inventory->setHardware({
        DESCRIPTION => "$arch/$uptime"
    });
}

sub _getUptime {
    my $boottime = getFirstMatch(
        pattern => qr/sec\s*=\s*(\d+)/,
        @_,
    );
    return unless $boottime;

    my $uptime = $boottime - time();
    return getFormatedGmTime($uptime);
}

1;
