package FusionInventory::Agent::Task::Inventory::Input::AIX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    return canRun('lscfg');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
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

    # get a first list of interfaces objects from lscfg
    my @interfaces = _parseLscfg(
        command => 'lscfg -v -l en*',
        logger  => $logger
    );

    # complete with empty interfaces objects from ifconfig
    push @interfaces,
        map { { DESCRIPTION => $_ } }
        split(/ /, getFirstLine(command => 'ifconfig -l'));

    foreach my $interface (@interfaces) {
        my $handle = getFileHandle(
            command => "lsattr -E -l $interface->{DESCRIPTION}",
            logger  => $logger
        );
        next unless $handle;

        while (my $line = <$handle>) {
            $interface->{IPADDRESS} = $1
                if $line =~ /^netaddr \s+ ($ip_address_pattern)/x;
            $interface->{IPMASK} = $1
                if $line =~ /^netmask \s+ ($ip_address_pattern)/x;
            $interface->{STATUS} = $1
                if $line =~ /^state \s+ (\w+)/x;
        }
        close $handle;
    }

    foreach my $interface (@interfaces) {
        $interface->{STATUS} = "Down" unless $interface->{IPADDRESS};
        $interface->{IPDHCP} = "No";

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK},
        );
    }

    return @interfaces;
}

sub _parseLscfg {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $interface;
    while (my $line = <$handle>) {
        if ($line =~ /^\s+ ent(\d+) \s+ \S+ \s+/x) {
            push @interfaces, $interface if $interface;
            undef $interface;
            # quick assertion: nothing else as ethernet interface
            $interface = {
                DESCRIPTION => "en$1",
                TYPE        => 'ethernet'
            };
        }
        if ($line =~ /Network Address\.+($alt_mac_address_pattern)/) {
            $interface->{MACADDR} = alt2canonical($1);
        }
    }
    close $handle;
    push @interfaces, $interface if $interface;

    return @interfaces;
}

1;
