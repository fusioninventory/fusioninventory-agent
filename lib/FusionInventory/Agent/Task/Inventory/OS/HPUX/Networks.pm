package FusionInventory::Agent::Task::Inventory::OS::HPUX::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);
use Sys::Hostname;

use FusionInventory::Agent::Tools;

#TODO Get driver pcislot virtualdev

sub isInventoryEnabled {
    return 
        can_run('lanadmin') &&
        can_run('lanscan') &&
        can_run('netstat') &&
        can_run('ifconfig') &&
        can_run('uname');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes = _getRoutes();
    my @interfaces = _getInterfaces($logger, $routes);
    foreach my $interface (@interfaces) {
        $inventory->addNetwork($interface);
    }

    # set global parameters
    my @ip_addresses =
        grep { ! /^127/ }
        grep { $_ }
        map { $_->{IPADDRESS} }
        @interfaces;

    $inventory->setHardware(
        IPADDR         => join('/', @ip_addresses),
        DEFAULTGATEWAY => $routes->{'default/0.0.0.0'}
    );
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
    my $name;
    my $lanid;
    my $ipmask;
    my $ipgateway;
    my $status;
    my $macaddr;
    my $speed;
    my $type;
    my $ipsubnet;
    my $description;
    my $ipaddress;

    for (`lanscan -iap`) {
        # Reinit variables
        $name="";
        $lanid="";
        $ipmask="";
        $ipgateway="";
        $status="";
        $macaddr="";
        $speed="";
        $type="";
        $ipsubnet="";
        $description="";
        $ipaddress="";
        next unless /^(\S+)\s(\S+)\s(\S+)\s+(\S+)/;
        $macaddr = $1;
        $name = $2;
        $lanid = $4;

        if ($macaddr =~ /^0x(..)(..)(..)(..)(..)(..)$/) {
            $macaddr = "$1:$2:$3:$4:$5:$6"
        }

        #print "name $name macaddr $macaddr lanid $lanid\n";
        for (`lanadmin -g $lanid`) {
            if (/Type.+=\s(.+)/) { $type = $1; }
            if (/Description\s+=\s(.+)/) { $description = $1; }
            if (/Speed.+=\s(\d+)/) {
                $speed = ($1 > 1000000)? $1/1000000 : $1; # in old version speed was given in Mbps and we want speed in Mbps
            }
            if (/Operation Status.+=\sdown\W/i) { $status = "Down"; } #It is not the only criteria
        } # for lanadmin
        #print "name $name macaddr $macaddr lanid $lanid speed $speed status $status \n";
        for (`ifconfig $name 2> /dev/null`) {
            if ( not $status and /$name:\s+flags=.*\WUP\W/ ) { #Its status is not reported as down in lanadmin -g
                $status = 'Up';
            }
            if (/inet\s(\S+)\snetmask\s(\S+)\s/) {
                $ipaddress=$1;
                $ipmask=$2;
                if ($ipmask =~ /(..)(..)(..)(..)/) {
                    $ipmask=sprintf ("%i.%i.%i.%i",hex($1),hex($2),hex($3),hex($4));
                }
            }
        } # For ifconfig
        $ipsubnet = join '.', unpack('C4C4C4C4', pack('B32', 
                unpack('B32', pack('C4C4C4C4', split(/\./, $ipaddress))) 
                & unpack('B32', pack('C4C4C4C4', split(/\./, $ipmask))) 
            ));

        $ipgateway = $routes->{$ipsubnet.'/'.$ipmask};
        # replace the $ipaddress (ie IP Address of the interface itself) by the default gateway IP adress if it exists
        if (defined($ipgateway) and $ipgateway eq $ipaddress and defined($routes->{'default/0.0.0.0'})) {
            $ipgateway = $routes->{'default/0.0.0.0'}
        }

        #Some cleanups
        if ($ipaddress eq '0.0.0.0') { $ipaddress = "" }
        if (not $ipaddress and not $ipmask and $ipsubnet eq '0.0.0.0') { $ipsubnet = "" }
        if (not $status) { $status = 'Down' }

        push @interfaces, {
            DESCRIPTION => $description,
            IPADDRESS => $ipaddress,
            IPMASK => $ipmask,
            IPSUBNET => $ipsubnet,
            MACADDR => $macaddr,
            STATUS => $status,
            TYPE => $type,
            SPEED => $speed,
            IPGATEWAY => $ipgateway,
#        PCISLOT => $pcislot,
#        DRIVER => $driver,
#        VIRTUALDEV => $virtualdev,
        };
    }

    return @interfaces;
}

1;
