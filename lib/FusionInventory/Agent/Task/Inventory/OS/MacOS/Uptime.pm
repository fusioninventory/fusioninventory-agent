package FusionInventory::Agent::Task::Inventory::OS::MacOS::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my $boottime = `sysctl -n kern.boottime 2>/dev/null`; # straight from the BSD module ;-)
    return 1 if $boottime;
    return;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    # stolen code from bsd.
    chomp (my $boottime = `sysctl -n kern.boottime`);
    $boottime = $1 if $boottime =~ /sec\s*=\s*(\d+)/;
    my $currenttime = time();
    my $uptime = $currenttime - $boottime;

    # ISO format string conversion
    $uptime = getFormatedGmTime($uptime);

    chomp(my $DeviceType =`uname -m`);
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
