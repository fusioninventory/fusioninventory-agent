package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my $modems = _getModemControllers($logger);

    return unless $modems;

    foreach my $modem (@$modems) {
        $inventory->addModem($modem);
    }
}

sub _getModemControllers {
    my ($logger, $file) = @_;

    my $controllers = getControllersFromLspci(logger => $logger, file => $file);
    my $modems;

    foreach my $controller (@$controllers) {
        next unless $controller->{NAME} =~ /modem/i;
        push @$modems, {
            DESCRIPTION => $controller->{NAME},
            NAME        => $controller->{MANUFACTURER},
        };
    }

    return $modems;
}

1;
