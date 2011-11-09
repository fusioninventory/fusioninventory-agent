package FusionInventory::Agent::Task::Inventory::Input::HPUX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

#TODO Get driver pcislot virtualdev

sub isEnabled {
    return canRun('lanscan');
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

    my @interfaces = _parseLanscan(
        command => 'lanscan -iap',
        logger  => $params{logger}
    );

    foreach my $interface (@interfaces) {
        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        # Some cleanups
        if ($interface->{IPADDRESS} eq '0.0.0.0') {
            $interface->{IPADDRESS} = "";
        }
        if (
            not $interface->{IPADDRESS} and
            not $interface->{IPMASK} and
            $interface->{IPSUBNET} eq '0.0.0.0'
        ) {
            $interface->{IPSUBNET} = "";
        }
    }

    return @interfaces;
}

sub _parseLanscan {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @interfaces;
    while (my $line = <$handle>) {
        next unless /^0x($alt_mac_address_pattern)\s(\S+)\s(\S+)\s+(\S+)/;
        my $interface = {
            MACADDR => alt2canonical($1),
            STATUS => 'Down'
        };
        my $name = $2;
        my $lanid = $4;

        my $lanadminInfo = _getLanadminInfo(
            command => "lanadmin -g $lanid", logger => $params{logger}
        );
        $interface->{TYPE}        = $lanadminInfo->{'Type (value)'};
        $interface->{DESCRIPTION} = $lanadminInfo->{Description};
        $interface->{SPEED}       = $lanadminInfo->{Speed} > 1000000 ?
                                        $lanadminInfo->{Speed} / 1000000 :
                                        $lanadminInfo->{Speed};

        my $ifconfigInfo = _getIfconfigInfo(
            command => "ifconfig $name", logger => $params{logger}
        );
        $interface->{STATUS}    = $ifconfigInfo->{status};
        $interface->{IPADDRESS} = $ifconfigInfo->{address};
        $interface->{IPMASK}    = $ifconfigInfo->{netmask};

        push @interfaces, $interface;
    }
    close $handle;

    return @interfaces;
}

sub _getLanadminInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        next unless $line =~ /^(\S.+\S) \s+ = \s (.+)$/x;
        $info->{$1} = $2;
    }
    close $handle;

    return $info;
}

sub _getIfconfigInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        if ($line =~ /<UP/) {
            $info->{status} = 'Up';
        }
        if ($line =~ /inet ($ip_address_pattern)/) {
            $info->{address} = $1;
        }
        if ($line =~ /netmask ($hex_ip_address_pattern)/) {
            $info->{netmask} = hex2canonical($1);
        }
    }
    close $handle;

    return $info;
}

1;
