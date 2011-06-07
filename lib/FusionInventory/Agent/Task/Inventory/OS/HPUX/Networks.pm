package FusionInventory::Agent::Task::Inventory::OS::HPUX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

#TODO Get driver pcislot virtualdev

sub isEnabled {
    return 
        can_run('lanadmin') &&
        can_run('lanscan') &&
        can_run('netstat') &&
        can_run('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my @interfaces = _getInterfaces($logger);

    my $routes = getRoutingTable(command => 'netstat -nr', logger => $logger);
    foreach my $interface (@interfaces) {
        next unless $interface->{IPSUBNET};
        $interface->{IPGATEWAY} = $routes->{$interface->{IPSUBNET}};
    }

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
        DEFAULTGATEWAY => $routes->{default}
    });
}

sub _getInterfaces {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => 'lanscan -iap'
    );
    return unless $handle;

    my @interfaces;
    while (my $line = <$handle>) {
        next unless /^(\S+)\s(\S+)\s(\S+)\s+(\S+)/;
        my $interface = {
            MACADDR => $1,
            STATUS => 'Down'
        };
        my $name = $2;
        my $lanid = $4;

        if ($interface->{MACADDR} =~ /^0x(..)(..)(..)(..)(..)(..)$/) {
            $interface->{MACADDR} = "$1:$2:$3:$4:$5:$6"
        }

        my $lanadminInfo = _getLanadminInfo(
            command => "lanadmin -g $lanid", logger => $logger
        );
        $interface->{TYPE}        = $lanadminInfo->{'Type (value)'};
        $interface->{DESCRIPTION} = $lanadminInfo->{Description};
        $interface->{SPEED}       = $lanadminInfo->{Speed} > 1000000 ?
                                        $lanadminInfo->{Speed} / 1000000 :
                                        $lanadminInfo->{Speed};

        my $ifconfigInfo = _getIfconfigInfo(
            command => "ifconfig $name", logger => $logger
        );
        $interface->{STATUS}    = $ifconfigInfo->{status};
        $interface->{IPADDRESS} = $ifconfigInfo->{address};
        $interface->{IPMASK}    = $ifconfigInfo->{netmask};

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
            $info->{netmask} = hex2quad($1);
        }
    }
    close $handle;

    return $info;
}

1;
