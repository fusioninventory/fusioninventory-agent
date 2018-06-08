package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Powersupply;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{powersupply};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $powersupplies = _getPowersupplies(logger => $logger);

    return unless $powersupplies;

    foreach my $powersupply (@$powersupplies) {
        $inventory->addEntry(
            section => 'POWERSUPPLIES',
            entry   => $powersupply
        );
    }
}

sub _getPowersupplies {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{39};

    my $powersupplies;

    foreach my $info (@{$infos->{39}}) {
        
        my $powersupply = {
            NAME           => $info->{'Name'},
            SERIALNUMBER   => $info->{'Serial Number'},
            MANUFACTURER   => $info->{'Manufacturer'},
            MODEL          => $info->{'Model Part Number'},
            CAPACITY       => 0,
            HOTREPLACEABLE => 0,
            PLUGGED        => 0
        };

        if ($info->{'Max Power Capacity'} &&
            $info->{'Max Power Capacity'} =~ /^(\d+) W$/) {
            $powersupply->{CAPACITY} = $1;
        }
	if ($info->{'Hot Replaceable'} &&
            $info->{'Hot Replaceable'} eq 'Yes') {
            $powersupply->{HOTREPLACEABLE} = 1;
        }
        if ($info->{'Plugged'} &&
            $info->{'Plugged'} eq 'Yes') {
            $powersupply->{PLUGGED} = 1;
        }
        
        push @$powersupplies, $powersupply;
    }
    return $powersupplies;
}

1;
