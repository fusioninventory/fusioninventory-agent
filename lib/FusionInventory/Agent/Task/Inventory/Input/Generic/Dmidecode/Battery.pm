package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Battery;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $battery = _getBattery(logger => $logger);

    return unless $battery;

    $inventory->addEntry(
        section => 'BATTERIES',
        entry   => $battery
    );
}

sub _getBattery {
    my $parser = getDMIDecodeParser(@_);

    my @handles = $parser->get_handles(dmitype => 22);
    return unless @handles;

    my $handle = $handles[0];

    my $battery = {
        NAME         => getSanitizedValue($handle, 'battery-name'),
        MANUFACTURER => getSanitizedValue($handle, 'battery-manufacturer'),
        SERIAL       => getSanitizedValue($handle, 'battery-serial-number'),
        CHEMISTRY    => getSanitizedValue($handle, 'battery-chemistry'),
    };

    $battery->{DATE} =
        _parseDate($handle->keyword('battery-manufacture-date'));

    my $capacity = $handle->keyword('battery-design-capacity');
    if ($capacity && $capacity =~ /(\d+) \s m(W|A)h$/x) {
        $battery->{CAPACITY} = $1;
    }

    my $voltage = $handle->keyword('battery-design-voltage');
    if ($voltage && $voltage =~ /(\d+) \s mV$/x) {
        $battery->{VOLTAGE} = $1;
    }

    return $battery;
}

sub _parseDate {
    my ($string) = @_;

    return unless $string;

    my ($day, $month, $year);
    if ($string =~ /(\d{1,2}) [\/-] (\d{1,2}) [\/-] (\d{2})/x) {
        $day   = $1;
        $month = $2;
        $year  = ($3 > 90 ? "19" : "20" ) . $3;
        return "$day/$month/$year";
    } elsif ($string =~ /(\d{4}) [\/-] (\d{1,2}) [\/-] (\d{1,2})/x) {
        $year  = $1;
        $day   = $2;
        $month = $3;
        return "$day/$month/$year";
    }

    return;
}

1;
