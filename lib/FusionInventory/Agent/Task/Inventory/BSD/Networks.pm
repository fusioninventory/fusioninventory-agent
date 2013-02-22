package FusionInventory::Agent::Task::Inventory::BSD::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::BSD;

sub isEnabled {
    return canRun('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes     = getRoutingTable(logger => $logger);
    my @interfaces = _getInterfaces(logger => $logger);

    foreach my $interface (@interfaces) {
        $interface->{IPGATEWAY} = $params{routes}->{$interface->{IPSUBNET}}
            if $interface->{IPSUBNET};

        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

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

        $interface->{VIRTUALDEV} =
            $interface->{DESCRIPTION} =~ /^(lo|vboxnet|vmnet|sit|tun|pflog|pfsync|enc|strip|plip|sl|ppp|faith)\d+$/;

        $interface->{IPDHCP} = getIpDhcp(
            $params{logger}, $interface->{DESCRIPTION}
        );
    }

    return @interfaces;
}

1;
