package FusionInventory::Agent::Task::Inventory::Input::Linux::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return 
        canRun('ifconfig') ||
        canRun('ip');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get the list of network interfaces
    my $routes = getRoutingTable(command => 'netstat -nr', logger => $logger);
    my @interfaces = _getInterfaces(logger => $logger, routes => $routes);

    foreach my $interface (@interfaces) {
        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

    # set global parameters
    my @ip_addresses =
        grep { ! /^127/ }
        grep { $_ }
        map { $_->{IPADDRESS} }
        @interfaces;

    $inventory->setHardware({
        IPADDR         => join('/', @ip_addresses),
        DEFAULTGATEWAY => $routes->{'0.0.0.0'}
    });
}

sub _getInterfaces {
    my (%params) = @_;

    my $logger = $params{logger};
    my $routes = $params{routes};

    my @interfaces = canRun("/sbin/ip") ?
        getInterfacesFromIp(logger => $logger):
        getInterfacesFromIfconfig(logger => $logger);

    foreach my $interface (@interfaces) {
        if (_isWifi($logger, $interface->{DESCRIPTION})) {
            $interface->{TYPE} = "Wifi";
        }

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        my ($driver, $pcislot) = _getUevent(
            $logger,
            $interface->{DESCRIPTION}
        );
        $interface->{DRIVER} = $driver if $driver;
        $interface->{PCISLOT} = $pcislot if $pcislot;

        $interface->{VIRTUALDEV} = _isVirtual(
            logger => $logger,
            name   => $interface->{DESCRIPTION},
            slot   => $interface->{PCISLOT}
        );

        $interface->{IPDHCP} = getIpDhcp($logger, $interface->{DESCRIPTION});
        $interface->{SLAVES} = _getSlaves($interface->{DESCRIPTION});

        if ($interface->{IPSUBNET}) {
            $interface->{IPGATEWAY} = $routes->{$interface->{IPSUBNET}};

            # replace '0.0.0.0' (ie 'default gateway') by the
            # default gateway IP adress if it exists
            if ($interface->{IPGATEWAY} and
                $interface->{IPGATEWAY} eq '0.0.0.0' and 
                $routes->{'0.0.0.0'}
            ) {
                $interface->{IPGATEWAY} = $routes->{'0.0.0.0'}
            }
        }
    }

    return @interfaces;
}

# Handle slave devices (bonding)
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

# Handle virtual devices (bridge)
sub _isVirtual {
    my (%params) = @_;

    return 0 if $params{slot};

    if (-d "/sys/devices/virtual/net/") {
        return -d "/sys/devices/virtual/net/$params{name}";
    }

    if (canRun('brctl')) {
        # Let's guess
        my %bridge;
        my $handle = getFileHandle(
            logger => $params{logger},
            command => 'brctl show'
        );
        my $line = <$handle>;
        while (my $line = <$handle>) {
            next unless $line =~ /^(\w+)\s/;
            $bridge{$1} = 1;
        }
        close $handle;

        return defined $bridge{$params{name}};
    }

    return 0;
}

sub _isWifi {
    my ($logger, $name) = @_;

    my $count = getLinesCount(
        logger  => $logger,
        command => "/sbin/iwconfig $name"
    );
    return $count > 2;
}

sub _getUevent {
    my ($logger, $name) = @_;

    my $file = "/sys/class/net/$name/device/uevent";
    my $handle = getFileHandle(file => $file);
    return unless $handle;

    my ($driver, $pcislot);
    while (<$handle>) {
        $driver = $1 if /^DRIVER=(\S+)/;
        $pcislot = $1 if /^PCI_SLOT_NAME=(\S+)/;
    }
    close $handle;

    return ($driver, $pcislot);
}

1;
