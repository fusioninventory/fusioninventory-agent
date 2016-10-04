package FusionInventory::Agent::Task::Inventory::MacOS::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

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
    my $boottime = return FusionInventory::Agent::Tools::MacOS::getBootTime(@_);
    return unless $boottime;

    my $uptime = time() - $boottime;
    return getFormatedGMTTime($uptime);
}

1;
