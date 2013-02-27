package FusionInventory::Agent::Task::Inventory::MacOS::Hostname;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $infos = getSystemProfilerInfos();

    my $hostname =
        $infos->{'Software'}->{'System Software Overview'}->{'Computer Name'};

    $inventory->setHardware({
        NAME => $hostname
    }) if $hostname;
}

1;
