package FusionInventory::Agent::Task::Inventory::MacOS::Batteries;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{batteries} &&
        canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $battery = _getBattery(logger => $params{logger}, format => 'xml');
    return unless $battery;

    $inventory->addEntry(
        section => 'BATTERIES',
        entry   => $battery
    );
}

sub _getBattery {
    my (%params) = @_;

    my $infos = FusionInventory::Agent::Tools::MacOS::getSystemProfilerInfos(
        type            => 'SPPowerDataType',
        %params,
        format => 'text'
    );

    my $infoBattery = $infos->{Power}->{'Battery Information'};

    my $battery = {
        SERIAL => $infoBattery->{'Model Information'}->{'Serial Number'},
        CAPACITY => $infoBattery->{'Charge Information'}->{'Full Charge Capacity (mAh)'},
        NAME => $infoBattery->{'Model Information'}->{'Device Name'},
        MANUFACTURER => $infoBattery->{'Model Information'}->{'Manufacturer'},
        VOLTAGE => $infoBattery->{'Voltage (mV)'},
        # CHEMISTRY => ,
        # DATE =>
    };

    return $battery;
}

1;
