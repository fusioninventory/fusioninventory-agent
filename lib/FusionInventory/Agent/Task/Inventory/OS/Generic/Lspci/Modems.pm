package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Modems;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $modems = getModemControllers();

    return unless $modems;

    foreach my $modem (@$modems) {
        $inventory->addModems($modem);
    }
}

sub getModemControllers {
    my ($file) = @_;

    my $controllers = getControllersFromLspci($file);
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
