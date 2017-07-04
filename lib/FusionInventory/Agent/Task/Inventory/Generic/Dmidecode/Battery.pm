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

    my @batteries = _getBatteries(logger => $logger);

    return unless @batteries;

    _mergeBatteries($inventory, @batteries);
}

sub _getBatteries {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{22};

    my $batteries;
    for my $info (@{$infos->{22}}) {
        my $data = _extractBatteryData($info);
        push @$batteries, $data if $data;
    }

    return (scalar @$batteries) > 0 ? $batteries : undef ;
}

sub _extractBatteryData {
    my ($info) = @_;

    my $battery = {
        NAME         => $info->{'Name'},
        MANUFACTURER => getCanonicalManufacturer($info->{'Manufacturer'}),
        SERIAL       => $info->{'Serial Number'} ||
            $info->{'SBDS Serial Number'},
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

sub _mergeBatteries {
    my ($inventory, $batteries) = @_;

    for my $batt (@$batteries) {
        # retrieve if the battery is already in inventory
        my $fields = {};
        if (defined $batt->{SERIAL}) {
            my $serial = $batt->{SERIAL};
            $serial = 0 if $serial =~ /^0+$/;
            $fields->{SERIAL} = $serial;
        }
        $fields->{NAME} = $batt->{NAME} if $batt->{NAME};
        my $battInInventory;
        my $battindex;
        # if we have some data to identify the battery already in inventory
        if (scalar (keys %$fields) >  0) {
            $battInInventory = $inventory->getBattery($fields);
        } else {
            # looking if we are in this special context :
            # we have one battery in inventory
            # and we have one battery to merge
            my $section = $inventory->getSection('BATTERIES');
            if (defined $section
                && (scalar @$section) == 1
                && (scalar @$batteries) == 1) {
                # in that special context, we take this unique battery found
                $battInInventory = $section->[0];
                # we also note the index
                $battindex = 0;
            }
        }
        my $newBatt;
        # if the battery is already in inventory
        if ($battInInventory) {
            # Getting the battery's index in inventory BATTERY section
            $battindex = $inventory->retrieveElementIndexInSection(
            'BATTERIES',
            {
                NAME => $battInInventory->{NAME},
                SERIAL => $battInInventory->{SERIAL}
            }
            ) if not defined $battindex;
            for my $field (keys %$batt) {
                # complete inventory if field is empty
                unless (defined $battInInventory->{$field}) {
                    $battInInventory->{$field} = $batt->{$field};
                }
            }
            $newBatt = $battInInventory;
        } else {
            $newBatt = $batt;
        }
        # insert battery at right index
        $inventory->setBatteryUsingIndex($newBatt, $battindex);
    }
}

1;
