package FusionInventory::Agent::Task::Inventory::Generic::Batteries::Upower;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

my $command = 'upower';

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{battery};
    return canRun($command);
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my @batteries = _getBatteriesFromUpower(%params);

    return unless @batteries;

    for my $batt (@batteries) {
        $inventory->addEntry(
            section => 'BATTERIES',
            entry => $batt
        );
    }
}

sub _getBatteriesFromUpower {
    my (%params) = @_;

    my @batteriesName = _getBatteriesNameFromUpower(
        %params,
        command => $command . ' --enumerate'
    );

    return unless @batteriesName;

    my @batteriesData = ();
    foreach my $battName (@batteriesName) {
        my $battData = _getBatteryDataFromUpower(
            %params,
            command => $command . ' -i ' . $battName
        );
        push @batteriesData, $battData;
    }

    return @batteriesData;
}

sub _getBatteriesNameFromUpower {
    my (%params) = @_;

    my @lines = getAllLines(
        %params
    );

    my @battName;
    for my $line (@lines) {
        if ($line =~ /^(.*\/battery_\S+)$/) {
            push @battName, $1;
        }
    }

    return @battName;
}

sub _getBatteryDataFromUpower {
    my (%params) = @_;

    my @lines = getAllLines(
        %params
    );

    my $data = {};
    for my $line (@lines) {
        if ($line =~ /^\s*(\S+):\s*(\S+(?:\s+\S+)*)$/) {
            $data->{$1} = $2;
        }
    }
    my $battData = {
        NAME => $data->{model} || '',
        CAPACITY => $data->{'energy-full'},
        VOLTAGE => $data->{voltage},
        CHEMISTRY => $data->{technology},
        SERIAL => defined $data->{serial} ? $data->{serial} : '',
        MANUFACTURER => getCanonicalManufacturer($data->{vendor})
            || getCanonicalManufacturer($data->{manufacturer})
            || undef
    };

    $battData->{SERIAL} = 0 if $battData->{SERIAL} =~ /^0+$/;

    return $battData;
}

1;
