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

    my $batteries = _getBatteries(logger => $logger);

    return unless $batteries;

    _mergeBatteries($inventory, $batteries);
}

sub _mergeBatteries {
    my ($inventory, $batteries) = @_;

    # testing case: one battery in inventory and also one retrieved by dmidecode
    my $section = $inventory->getSection('BATTERIES');
    if (ref $section eq 'ARRAY'
        && scalar @$section == 1
        && scalar @$batteries == 1) {
        $inventory->addEntry(
            section => 'BATTERIES',
            entry => $batteries->[0],
            identity => [ sub {return 1;} ]
        );
    } else {
        for my $batt (@$batteries) {
            $inventory->addEntry(
                section  => 'BATTERIES',
                entry    => $batt,
                identity => [
                    sub {
                        my ($battFromDmiDecode, $battInInventory) = @_;
                        return $battFromDmiDecode->{NAME}
                            && $battInInventory->{NAME}
                            && $battFromDmiDecode->{NAME} eq $battInInventory->{NAME}
                            && defined $battFromDmiDecode->{SERIAL}
                            && defined $battInInventory->{SERIAL}
                            && ($battFromDmiDecode->{SERIAL} eq $battInInventory->{SERIAL}
                            # dmidecode sometimes returns hexadecimal values for Serial number
                            || hex2dec($battFromDmiDecode->{SERIAL}) eq $battInInventory->{SERIAL});
                    },
                    sub {
                        my ($battFromDmiDecode, $battInInventory) = @_;
                        return $battFromDmiDecode->{NAME}
                            && $battInInventory->{NAME}
                            && $battFromDmiDecode->{NAME} eq $battInInventory->{NAME}
                            && !defined $battFromDmiDecode->{SERIAL}
                            && !defined $battInInventory->{SERIAL};
                    }
                ]
            );
        }
    }
}

sub _getBatteries {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{22};

    my $batteries = [];
    for my $info (@{$infos->{22}}) {
        my $data = _extractBatteryData($info);
        push @$batteries, $data if $data;
    }

    return $batteries ? $batteries : undef;
}

sub _extractBatteryData {
    my ($info) = @_;

    my $battery = {
        NAME         => $info->{'Name'},
        MANUFACTURER => getCanonicalManufacturer($info->{'Manufacturer'}),
        SERIAL       => defined $info->{'Serial Number'} ?
            $info->{'Serial Number'} :
                defined $info->{'SBDS Serial Number'} ?
                $info->{'SBDS Serial Number'} :
                '',
        CHEMISTRY    => $info->{'Chemistry'} ||
            $info->{'SBDS Chemistry'},
    };

    if ($info->{'Manufacture Date'}) {
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

    $battery->{SERIAL} = 0 if $battery->{SERIAL} =~ /^0+$/;

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


1;
