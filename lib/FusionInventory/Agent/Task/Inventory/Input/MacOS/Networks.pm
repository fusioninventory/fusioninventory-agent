package FusionInventory::Agent::Task::Inventory::Input::MacOS::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);

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
    my $routes = getRoutingTable(logger => $logger);
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
    }

    return @interfaces;
}

sub _parseIfconfig {

    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $interface;

    while (my $line = <$handle>) {
        if ($line =~ /^(\S+):/) {
            # new interface
            push @interfaces, $interface if $interface;
            $interface = {
                STATUS      => 'Down',
                DESCRIPTION => $1,
                VIRTUALDEV  => 1
            };
        }

        if ($line =~ /inet ($ip_address_pattern)/) {
            $interface->{IPADDRESS} = $1;
        }
        if ($line =~ /inet6 (\S+)/) {
            $interface->{IPADDRESS6} = $1;
            # Drop the interface from the address. e.g:
            # fe80::1%lo0
            # fe80::214:51ff:fe1a:c8e2%fw0
            $interface->{IPADDRESS6} =~ s/%.*$//;
        }
        if ($line =~ /netmask 0x($hex_ip_address_pattern)/) {
            $interface->{IPMASK} = hex2canonical($1);
        }
        if ($line =~ /(?:address:|ether|lladdr) ($mac_address_pattern)/) {
            $interface->{MACADDR} = $1;
        }
        if ($line =~ /mtu (\S+)/) {
            $interface->{MTU} = $1;
        }
        if ($line =~ /media (\S+)/) {
            $interface->{TYPE} = $1;
        }
        if ($line =~ /status:\s+active/i) {
            $interface->{STATUS} = 'Up';
        }
        if ($line =~ /supported\smedia:/) {
            $interface->{VIRTUALDEV} = 0;
        }
    }
    close $handle;

    # last interface
    push @interfaces, $interface if $interface;

    return @interfaces;
}

1;
