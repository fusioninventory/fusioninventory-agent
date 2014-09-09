package FusionInventory::Agent::Task::Inventory::BSD::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::BSD;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{network};
    return canRun('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @interfaces = _getInterfaces(logger => $logger);
    foreach my $interface (@interfaces) {
        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

    my $routes = getRoutingTable(logger => $logger);
    $inventory->setHardware({
        DEFAULTGATEWAY => $routes->{'0.0.0.0'}
    });
}

sub _getInterfaces {
    my (%params) = @_;

    my @interfaces = getInterfacesFromIfconfig(
        logger => $params{logger}
    );

    foreach my $interface (@interfaces) {
        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        $interface->{IPDHCP} = getIpDhcp(
            $params{logger},
            $interface->{DESCRIPTION}
        );

        if ($interface->{DESCRIPTION} =~ m/^(lo|vboxnet|vmnet|sit|tun|pflog|pfsync|enc|strip|plip|sl|ppp|faith)/) {
            $interface->{VIRTUALDEV} = 1;

            if ($interface->{DESCRIPTION} =~ m/^lo/) {
                $interface->{TYPE} = 'loopback';
            }

            if ($interface->{DESCRIPTION} =~ m/^ppp/) {
                $interface->{TYPE} = 'dialup';
            }
        } else {
            $interface->{VIRTUALDEV} = 0;
        }
    }

    return @interfaces;
}

1;
