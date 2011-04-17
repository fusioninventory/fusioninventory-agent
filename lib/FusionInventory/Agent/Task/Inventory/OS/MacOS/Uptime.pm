package FusionInventory::Agent::Task::Inventory::OS::MacOS::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return getFirstLine(command => 'sysctl -n kern.boottime');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # stolen code from bsd.
    my $boottime = getFirstLine(command => 'sysctl -n kern.boottime');
    $boottime = $1 if $boottime =~ /sec\s*=\s*(\d+)/;
    my $currenttime = time();
    my $uptime = $currenttime - $boottime;

    # ISO format string conversion
    $uptime = getFormatedGmTime($uptime);

    my $DeviceType = getFirstLine(command => 'uname -m');
    $inventory->setHardware({
        DESCRIPTION => "$DeviceType/$uptime"
    });
}

1;
