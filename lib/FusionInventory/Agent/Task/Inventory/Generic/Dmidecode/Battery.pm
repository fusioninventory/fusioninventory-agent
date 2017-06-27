package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Battery;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{battery};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $battery = _getBattery(logger => $logger);

    my $batteryAdditionalData = _getBatteryFromUpower(%params);
    $battery = _mergeData($battery, $batteryAdditionalData);

    return unless $battery;

    $inventory->addEntry(
        section => 'BATTERIES',
        entry   => $battery
    );
}

sub _getBattery {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{22};

    my $info    = $infos->{22}->[0];

    my $battery = {
        NAME         => $info->{'Name'},
        MANUFACTURER => $info->{'Manufacturer'},
        SERIAL       => $info->{'Serial Number'} ||
                        $info->{'SBDS Serial Number'},
        CHEMISTRY    => $info->{'Chemistry'} ||
                        $info->{'SBDS Chemistry'},
    };

    if      ($info->{'Manufacture Date'}) {
        $battery->{DATE} = _parseDate($info->{'Manufacture Date'});
    } elsif ($info->{'SBDS Manufacture Date'}) {
        $battery->{DATE} = _parseDate($info->{'SBDS Manufacture Date'});
    }

    if ($info->{'Design Capacity'} &&
        $info->{'Design Capacity'} =~ /(\d+) \s m[WA]h$/x) {
        $battery->{CAPACITY} = $1;
    }

    if ($info->{'Design Voltage'} &&
        $info->{'Design Voltage'} =~ /(\d+) \s mV$/x) {
        $battery->{VOLTAGE} = $1;
    }

    return $battery;
}

sub _parseDate {
    my ($string) = @_;

    my ($day, $month, $year);
    if ($string =~ /(\d{1,2}) [\/-] (\d{1,2}) [\/-] (\d{4})/x) {
        $month = $1;
        $day   = $2;
        $year  = $3;
        return "$day/$month/$year";
    } elsif ($string =~ /(\d{4}) [\/-] (\d{1,2}) [\/-] (\d{1,2})/x) {
        $year  = $1;
        $month = $2;
        $day   = $3;
        return "$day/$month/$year";
    } elsif ($string =~ /(\d{1,2}) [\/-] (\d{1,2}) [\/-] (\d{2})/x) {
        $month = $1;
        $day = $2;
        $year = ($3 > 90 ? "19" : "20" ).$3;
        return "$day/$month/$year";
    }
    return;
}

sub _getBatteryFromUpower {
    my (%params) = @_;

    my $command = 'upower';
    return unless canRun($command);

    my $batteryName = _getBatteryNameFromUpower(
        %params,
        command => $command . ' --enumerate'
    );

    return unless $batteryName;

    my $battData = _getBatteryDataFromUpower(
        %params,
        command => $command . ' -i ' . $batteryName
    );

    return $battData;
}

sub _getBatteryNameFromUpower {
    my (%params) = @_;

    my @lines = getAllLines(
        %params
    );

    my $battName;
    for my $line (@lines) {
        if ($line =~ /^(.*\/battery_BAT1)$/) {
            $battName = $1;
            last;
        }
    }

    return $battName;
}

sub _getBatteryDataFromUpower {
    my (%params) = @_;

    my @lines = getAllLines(
        %params
    );

    my $data = {};
    for my $line (@lines) {
        if ($line =~ /^\s*(\S+):\s*(\S+)$/) {
            $data->{$1} = $2;
        }
    }
    my $battData = {
        NAME => $data->{model} || '',
        CAPACITY => $data->{'energy-full'},
        VOLTAGE => $data->{voltage},
        CHEMISTRY => $data->{technology}
    };

    return $battData;
}

sub _mergeData {
    my ($batt, $additionalData) = @_;

    if ($additionalData->{NAME} && !$batt->{NAME}) {
        $batt->{NAME} = $additionalData->{NAME};
        if ($batt->{MANUFACTURER}) {
            $batt->{NAME} = $batt->{MANUFACTURER} . ' ' . $batt->{NAME};
        }
    }
    $batt->{CHEMISTRY} = $additionalData->{CHEMISTRY} if ($additionalData->{CHEMISTRY} && !($batt->{CHEMISTRY}));
    $batt->{CAPACITY} = $additionalData->{CAPACITY} if ($additionalData->{CAPACITY} && !($batt->{CAPACITY}));
    $batt->{VOLTAGE} = $additionalData->{VOLTAGE} if ($additionalData->{VOLTAGE} && !($batt->{VOLTAGE}));

    return $batt;
}

1;
