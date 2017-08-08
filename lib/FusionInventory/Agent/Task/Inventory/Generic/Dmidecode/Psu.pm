package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu;

use strict;
use warnings;

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
    my $logger    = $params{logger};

    my $infos = getDmidecodeInfos(logger => $logger);

    return unless $infos->{39};

    foreach my $info (@{$infos->{39}}) {
        my $psu = {
            PARTNUM => $info->{'Model Part Number'},
            SERIAL  => $info->{'Serial Number'},
            VENDOR  => $info->{'Manufacturer'},
        };
        
        $inventory->addEntry(
            section => 'PSU',
            entry   => $psu
        );
    }
}

1;
