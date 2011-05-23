package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $modem (_getModemControllers(logger => $logger)) {
        $inventory->addEntry(
            section => 'MODEMS',
            entry   => $modem
        );
    }
}

sub _getModemControllers {
    my @modems;

    foreach my $device (getPCIDevices(@_)) {
        next unless $device->{NAME} =~ /modem/i;
        push @modems, {
            DESCRIPTION => $device->{NAME},
            NAME        => $device->{MANUFACTURER},
        };
    }

    return @modems;
}

1;
