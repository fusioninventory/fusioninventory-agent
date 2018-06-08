package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{psu};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $infos = getDmidecodeInfos(%params);

    return unless $infos->{39};

    foreach my $info (@{$infos->{39}}) {
        # Skip battery
        next if $info->{'Type'} && $info->{'Type'} eq 'Battery';

        my $psu = {
            PARTNUM      => $info->{'Model Part Number'},
            SERIALNUMBER => $info->{'Serial Number'},
            MANUFACTURER => $info->{'Manufacturer'},
        };

        # Add other informations if present
        $psu->{'NAME'} = $info->{'Name'}
            if $info->{'Name'};
        $psu->{'STATUS'} = $info->{'Status'}
            if $info->{'Status'};
        $psu->{'PLUGGED'} = $info->{'Plugged'}
            if $info->{'Plugged'};
        $psu->{'LOCATION'} = $info->{'Location'}
            if $info->{'Location'};
        $psu->{'POWER_MAX'} = $info->{'Max Power Capacity'}
            if $info->{'Max Power Capacity'};
        $psu->{'HOTREPLACEABLE'} = $info->{'Hot Replaceable'}
            if $info->{'Hot Replaceable'};

        $inventory->addEntry(
            section => 'POWERSUPPLIES',
            entry   => $psu
        );
    }
}

1;
