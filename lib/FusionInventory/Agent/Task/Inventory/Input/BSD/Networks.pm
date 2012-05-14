package FusionInventory::Agent::Task::Inventory::Input::BSD::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;

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

    my @interfaces = _parseIfconfig(
        command => '/sbin/ifconfig -a',
        logger  =>  $params{logger}
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

sub _parseIfconfig {

    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces; # global list of interfaces
    my @addresses;  # per-interface list of addresses
    my $interface;  # current interface

    while (my $line = <$handle>) {
        if ($line =~ /^(\S+): flags=\d+<([^>]+)> metric \d+ mtu (\d+)/) {

            if (@addresses) {
                push @interfaces, @addresses;
                undef @addresses;
            } else {
                push @interfaces, $interface if $interface;
            }

            $interface = {
                DESCRIPTION => $1,
                MTU         => $3
            };
            my $flags = $2;

            foreach my $flag (split(/,/, $flags)) {
                next unless $flag eq 'UP' || $flag eq 'DOWN';
                $interface->{STATUS} = ucfirst(lc($flag));
            }
        } elsif ($line =~ /(?:address:|ether|lladdr) ($mac_address_pattern)/) {
            $interface->{MACADDR} = $1;

        } elsif ($line =~ /inet ($ip_address_pattern) (?:--> $ip_address_pattern )?netmask 0x($hex_ip_address_pattern)/) {
            my $address = $1;
            my $mask    = hex2canonical($2);
            my $subnet  = getSubnetAddress($address, $mask);

            push @addresses, {
                IPADDRESS   => $address,
                IPMASK      => $mask,
                IPSUBNET    => $subnet,
                STATUS      => $interface->{STATUS},
                DESCRIPTION => $interface->{DESCRIPTION},
                MACADDR     => $interface->{MACADDR},
                MTU         => $interface->{MTU}
            };
        } elsif ($line =~ /inet6 ([\w:]+)\S* prefixlen (\d+)/) {
            my $address = $1;
            my $mask    = getNetworkMaskIPv6($2);
            my $subnet  = getSubnetAddressIPv6($address, $mask);

            push @addresses, {
                IPADDRESS6  => $address,
                IPMASK6     => $mask,
                IPSUBNET6   => $subnet,
                STATUS      => $interface->{STATUS},
                DESCRIPTION => $interface->{DESCRIPTION},
                MACADDR     => $interface->{MACADDR},
                MTU         => $interface->{MTU}
            };

        }

        if ($line =~ /media: (\S+)/) {
            $interface->{TYPE} = $1;
            $_->{TYPE} = $1 foreach @addresses;
        }
    }
    close $handle;

    # last interface
    if (@addresses) {
        push @interfaces, @addresses;
    } else {
        push @interfaces, $interface if $interface;
    }

    return @interfaces;
}

1;
