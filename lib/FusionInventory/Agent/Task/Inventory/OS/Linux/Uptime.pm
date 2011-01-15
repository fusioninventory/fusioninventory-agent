package FusionInventory::Agent::Task::Inventory::OS::Linux::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return -r '/proc/uptime';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Uptime
    my $uptime = getFirstLine(file => '/proc/uptime', logger => $logger);
    $uptime =~ s/^(.+)\s+.+/$1/;

    # ISO format string conversion
    $uptime = getFormatedGmTime($uptime);

    my $DeviceType = getFirstLine(command => 'uname -m');
    $inventory->setHardware(
        DESCRIPTION => "$DeviceType/$uptime"
    );
}

1;
