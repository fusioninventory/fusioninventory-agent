package FusionInventory::Agent::Task::Inventory::OS::HPUX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Regexp;

#TODO Get driver pcislot virtualdev

sub isInventoryEnabled {
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
    my $routes = _getRoutes();
    my @interfaces = _getInterfaces($logger, $routes);
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
        DEFAULTGATEWAY => $routes->{'default/0.0.0.0'}
    });
}


sub _getRoutes {
    my $handle = getFileHandle(
        command => 'netstat -nrv'
    );
    return unless $handle;

    my $routes;
    while (my $line = <$handle>) {
        next unless $line =~ /^
            ((?:$ip_address_pattern|default)\/$ip_address_pattern)
            \s+
            ($ip_address_pattern)
        /x;
        $routes->{$1} = $2 unless defined $routes->{$1};
    }
    close $handle;

    return $routes;
}

sub _getInterfaces {
    my ($logger, $routes) = @_;

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

        foreach (`lanadmin -g $lanid`) {
            if (/Type.+=\s(.+)/) {
                $interface->{TYPE} = $1;
            }
            if (/Description\s+=\s(.+)/) {
                $interface->{DESCRIPTION} = $1;
            }
            if (/Speed.+=\s(\d+)/) {
                # in old version speed was given in Mbps and we want speed
                # in Mbps
                $interface->{SPEED} = ($1 > 1000000)? $1/1000000 : $1;
            }
        }

        foreach (`ifconfig $name 2> /dev/null`) {
            if (/$name:\s+flags=.*\WUP\W/ ) {
                # its status is not reported as down in lanadmin -g
                $interface->{STATUS} = 'Up';
            }
            if (/inet\s(\S+)\snetmask\s(\S+)\s/) {
                $interface->{IPADDRESS} = $1;
                $interface->{IPMASK} = $2;
                if ($interface->{IPMASK} =~ /(..)(..)(..)(..)/) {
                    $interface->{IPMASK} =
                        sprintf ("%i.%i.%i.%i",hex($1),hex($2),hex($3),hex($4));
                }
            }
        }

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        # the gateway address is the gateway for the interface subnet
        # unless on the gateway itself, where it is the default gateway
        my $subnet = $interface->{IPSUBNET} . '/' . $interface->{IPMASK};
        $interface->{IPGATEWAY} =
            $routes->{$subnet} ne $interface->{IPADDRESS} ?
                $routes->{$subnet}          :
                $routes->{'default/0.0.0.0'};

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

1;
