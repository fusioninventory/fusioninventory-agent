package FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;
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
        IPADDR => join('/', @ip_addresses),
        DEFAULTGATEWAY => $routes->{default}
    });
}

sub _getInterfaces {
    my (%params) = @_;

    my $logger = $params{logger};

    my @interfaces = _parseLscfg(
        command => 'lscfg -v -l en*',
        logger  => $logger
    );

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

        if ($interface->{IPSUBNET}) {
            $interface->{IPGATEWAY} = $params{routes}->{$interface->{IPSUBNET}};
        }
    }

    return @interfaces;
}

sub _parseLscfg {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $interface;
    while (my $line = <$handle>) {
        if ($line =~ /^\s+ ent(\d+) \s+ \S+ \s+ (.+)/x) {
            push @interfaces, $interface if $interface;
            undef $interface;
            $interface->{TYPE} = $2;
            $interface->{DESCRIPTION} = "en$1";
        }
        if ($line =~ /Network Address\.+($hex_mac_address_pattern)/) {
            $interface->{MACADDR} = join2split($1);
        }
    }
    close $handle;
    push @interfaces, $interface if $interface;

    return @interfaces;
}

1;
