package FusionInventory::Agent::Task::Inventory::OS::HPUX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

#TODO Get driver pcislot virtualdev

sub isInventoryEnabled {
    return 
        can_run("lanadmin") &&
        can_run("lanscan") &&
        can_run("netstat") &&
        can_run("ifconfig") &&
        can_run("uname");
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

    my $routes;
    foreach (`netstat -nrv`) {
        if (/^(\S+\/\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/) {
            $routes->{$1} = $2 if not defined $routes->{$1}; #Just keep the first one
        }
    }
    return $routes;
}

sub _getInterfaces {
    my ($logger, $routes) = @_;

    my @interfaces;

    foreach (`lanscan -iap`) {
        my ($interface, $name, $lanid);
        next unless /^(\S+)\s(\S+)\s(\S+)\s+(\S+)/;
        $interface->{MACADDR} = $1;
        $name = $2;
        $lanid = $4;

        if ($interface->{MACADDR} =~ /^0x(..)(..)(..)(..)(..)(..)$/) {
            $interface->{MACADDR} = "$1:$2:$3:$4:$5:$6"
        }

        foreach (`lanadmin -g $lanid`) {
            if (/Type.+=\s(.+)/) { $interface->{TYPE} = $1; }
            if (/Description\s+=\s(.+)/) { $interface->{DESCRIPTION} = $1; }
            if (/Speed.+=\s(\d+)/) {
                $interface->{SPEED} = ($1 > 1000000)? $1/1000000 : $1; # in old version speed was given in Mbps and we want speed in Mbps
            }
            if (/Operation Status.+=\sdown\W/i) { $interface->{STATUS} = "Down"; } #It is not the only criteria
        }

        foreach (`ifconfig $name 2> /dev/null`) {
            if ( not $interface->{STATUS} and /$name:\s+flags=.*\WUP\W/ ) { #Its status is not reported as down in lanadmin -g
                $interface->{STATUS} = 'Up';
            }
            if (/inet\s(\S+)\snetmask\s(\S+)\s/) {
                $interface->{IPADDRESS} = $1;
                $interface->{IPMASK} = $2;
                if ($interface->{IPMASK} =~ /(..)(..)(..)(..)/) {
                    $interface->{IPMASK} = sprintf ("%i.%i.%i.%i",hex($1),hex($2),hex($3),hex($4));
                }
            }
        }

        $interface->{IPSUBNET} = join '.', unpack('C4C4C4C4', pack('B32', 
                unpack('B32', pack('C4C4C4C4', split(/\./, $interface->{IPADDRESS}))) 
                & unpack('B32', pack('C4C4C4C4', split(/\./, $interface->{IPMASK}))) 
            ));

        $interface->{IPGATEWAY} = $routes->{$interface->{IPSUBNET} . '/' . $interface->{IPMASK}};
        # replace the $ipaddress (ie IP Address of the interface itself) by the default gateway IP adress if it exists
        if (
            defined $interface->{IPGATEWAY} and
            $interface->{IPGATEWAY} eq $interface->{IPADDRESS} and
            defined $routes->{'default/0.0.0.0'}
        ) {
            $interface->{IPGATEWAY} = $routes->{'default/0.0.0.0'}
        }

        # Some cleanups
        if ($interface->{IPADDRESS} eq '0.0.0.0') { $interface->{IPADDRESS} = "" }
        if (not $interface->{IPADDRESS} and not $interface->{IPMASK} and $interface->{IPSUBNET} eq '0.0.0.0') { $interface->{IPSUBNET} = "" }
        if (not $interface->{STATUS}) { $interface->{STATUS} = 'Down' }

        push @interfaces, $interface;
    }

    return @interfaces;
}

1;
