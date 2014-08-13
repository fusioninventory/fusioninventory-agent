package FusionInventory::Agent::Task::Inventory::Linux::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{network};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $routes = getRoutingTable(command => 'netstat -nr', logger => $logger);
    my @interfaces = _getInterfaces(logger => $logger);

    foreach my $interface (@interfaces) {
        $interface->{IPGATEWAY} = $routes->{$interface->{IPSUBNET}}
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

            $interface->{VIRTUALDEV} = 0;

            # check if it is a wifi interface, otherwise assume ethernet
            if (-d "/sys/class/net/$interface->{DESCRIPTION}/wireless") {
                $interface->{TYPE} = 'wifi';
                my $info = _parseIwconfig(name => $interface->{DESCRIPTION});
                $interface->{WIFI_MODE}    = $info->{mode};
                $interface->{WIFI_SSID}    = $info->{SSID};
                $interface->{WIFI_BSSID}   = $info->{BSSID};
                $interface->{WIFI_VERSION} = $info->{version};
            } else {
                $interface->{TYPE} = 'ethernet';
            }

        } else {
            $interface->{VIRTUALDEV} = 1;

            if ($interface->{DESCRIPTION} eq 'lo') {
                $interface->{TYPE} = 'loopback';
            }

            if ($interface->{DESCRIPTION} =~ m/^ppp/) {
                $interface->{TYPE} = 'dialup';
            }

            # check if it is an alias or a tagged interface
            if ($interface->{DESCRIPTION} =~ m/^([\w\d]+)[:.]\d+$/) {
                $interface->{TYPE} = 'alias';
                $interface->{BASE} = $1;
             }
            # check if is is a bridge
            if (-d "/sys/class/net/$interface->{DESCRIPTION}/brif") {
                $interface->{SLAVES} = _getSlaves($interface->{DESCRIPTION});
                $interface->{TYPE}   = 'bridge';
            }

            # check if it is a bonding master
            if (-d "/sys/class/net/$interface->{DESCRIPTION}/bonding") {
                $interface->{SLAVES} = _getSlaves($interface->{DESCRIPTION});
                $interface->{TYPE}   = 'aggregate';
            }
        }

        # check if it is a bonding slave
        if (-d "/sys/class/net/$interface->{DESCRIPTION}/bonding_slave") {
            $interface->{MACADDR} = getFirstMatch(
                command => "ethtool -P $interface->{DESCRIPTION}",
                pattern => qr/^Permanent address: ($mac_address_pattern)$/,
                logger  => $logger
            );
        }

        if (-r "/sys/class/net/$interface->{DESCRIPTION}/speed") {
            $interface->{SPEED} = getFirstLine(
                file => "/sys/class/net/$interface->{DESCRIPTION}/speed"
            );
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

    my @slaves =
        map { $_ =~ /\/lower_(\w+)$/ }
        glob("/sys/class/net/$name/lower_*");

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

sub _parseIwconfig {
    my (%params) = @_;

    my $handle = getFileHandle(
        %params,
        command => $params{name} ? "iwconfig $params{name}" : undef
    );
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        $info->{version} = $1
            if $line =~ /IEEE (\S+)/;
        $info->{SSID} = $1
            if $line =~ /ESSID:"([^"]+)"/;
        $info->{mode} = $1
            if $line =~ /Mode:(\S+)/;
        $info->{BSSID} = $1
            if $line =~ /Access Point: ($mac_address_pattern)/;
    }

    close $handle;

    return $info;
}

1;
