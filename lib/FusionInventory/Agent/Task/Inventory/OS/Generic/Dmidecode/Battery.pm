package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Battery;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $battery = _getBattery(logger => $logger);

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
        SERIAL       => $info->{'Serial Number'},
        CHEMISTRY    => $info->{'Chemistry'},
    };

    if ($info->{'Manufacture Date'}) {
        $battery->{DATE} = _parseDate($info->{'Manufacture Date'});
    }

    if ($info->{Capacity} && $info->{Capacity} =~ /(\d+) \s m(W|A)h$/x) {
        $battery->{CAPACITY} = $1;
    }

    if ($info->{Voltage} && $info->{Voltage} =~ /(\d+) \s mV$/x) {
        $battery->{VOLTAGE} = $1;
    }

    return $battery;
}

sub _parseDate {
    my ($string) = @_;

    if ($string =~ /(\d{1,2})([\/-])(\d{1,2})([\/-])(\d{2})/) {
        my $d = $1;
        my $m = $3;
        my $y = ($5>90?"19":"20").$5;

        return "$1/$3/$y";
    } elsif ($string =~ /(\d{4})([\/-])(\d{1,2})([\/-])(\d{1,2})/) {
        my $y = ($5>90?"19":"20").$1;
        my $d = $3;
        my $m = $5;

        return "$d/$m/$y";
    }
}

1;
