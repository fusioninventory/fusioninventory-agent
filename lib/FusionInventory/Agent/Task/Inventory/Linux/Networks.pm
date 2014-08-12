package FusionInventory::Agent::Task::Inventory::Linux::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $routes = getRoutingTable(command => 'netstat -nr', logger => $logger);
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

    my $logger = $params{logger};

    my @interfaces = _getInterfacesBase(logger => $logger);

    foreach my $interface (@interfaces) {
        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        $interface->{IPDHCP} = getIpDhcp(
            $logger,
            $interface->{DESCRIPTION}
        );

        # check if it is a physical interface
        if (-d "/sys/class/net/$interface->{DESCRIPTION}/device") {
            my ($driver, $pcislot) = _getUevent(
                $interface->{DESCRIPTION}
            );
            $interface->{DRIVER} = $driver if $driver;
            $interface->{PCISLOT} = $pcislot if $pcislot;
        }

        # check if it is a wifi interface
        if (-d "/sys/class/net/$interface->{DESCRIPTION}/wireless") {
            $interface->{TYPE} = "wifi";
        }

        # check if is is a bridge
        if (-d "/sys/class/net/$interface->{DESCRIPTION}/brif") {
            $interface->{VIRTUALDEV} = 1;
        }

        # check if it is a bond
        if (-d "/sys/class/net/$interface->{DESCRIPTION}/bonding") {
            $interface->{SLAVES}     = _getSlaves($interface->{DESCRIPTION});
            $interface->{VIRTUALDEV} = 1;
        }

        # check if it is a virtual interface
        if (-d "/sys/devices/virtual/net/$interface->{DESCRIPTION}") {
            $interface->{VIRTUALDEV} = 1;
        }
    }

    return @interfaces;
}

sub _getInterfacesBase {
    my (%params) = @_;

    my $logger = $params{logger};
    $logger->debug("retrieving interfaces list...");

    if (canRun('/sbin/ip')) {
        my @interfaces = getInterfacesFromIp(logger => $logger);
        $logger->debug_result('running /sbin/ip command', @interfaces);
        return @interfaces if @interfaces;
    } else {
        $logger->debug_absence($logger, '/sbin/ip command');
    }

    if (canRun('/sbin/ifconfig')) {
        my @interfaces = getInterfacesFromIfconfig(logger => $logger);
        $logger->debug_result('running /sbin/ifconfig command', @interfaces);
        return @interfaces if @interfaces;
    } else {
        $logger->debug_absence('/sbin/ifconfig command');
    }

    return;
}

sub _getSlaves {
    my ($name) = @_;

    my @slaves = ();
    while (my $slave = glob("/sys/class/net/$name/slave_*")) {
        if ($slave =~ /\/slave_(\w+)/) {
            push(@slaves, $1);
        }
    }

    return join (",", @slaves);
}

sub _getUevent {
    my ($name) = @_;

    my $file = "/sys/class/net/$name/device/uevent";
    my $handle = getFileHandle(file => $file);
    return unless $handle;

    my ($driver, $pcislot);
    while (my $line = <$handle>) {
        $driver = $1 if $line =~ /^DRIVER=(\S+)/;
        $pcislot = $1 if $line =~ /^PCI_SLOT_NAME=(\S+)/;
    }
    close $handle;

    return ($driver, $pcislot);
}

1;
