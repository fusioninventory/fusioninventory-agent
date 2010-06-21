package FusionInventory::Agent::Task::Inventory::OS::HPUX::Networks;

use strict;
use warnings;

#TODO Get driver pcislot virtualdev

sub isInventoryEnabled {
    return 
        can_run("lanadmin") &&
        can_run("lanscan") &&
        can_run("netstat") &&
        can_run("ifconfig") &&
        can_run("hostname") &&
        can_run("uname");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

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

    my $hostname = 'Unknown';
    if ( `hostname` =~ /(\S+)/ ) {
        $hostname=$1
    } elsif ( `uname -n` =~ /(\S+)/ ) { # It should never reach here, as `hostname` should never fail!
        $hostname=$1
    }

    for ( `grep $hostname /etc/hosts ` ) {
        if ( /(^\d+\.\d+\.\d+\.\d+)\s+/ ) {
            $inventory->setHardware({IPADDR => $1});
            last;
        }
    }

    my %gateway;
    foreach (`netstat -nrv`) {
        if (/^(\S+\/\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/) {
            $gateway{$1} = $2 if not defined $gateway{$1}; #Just keep the first one
        }
    }
    if (defined ($gateway{'default/0.0.0.0'})) {
        $inventory->setHardware({
                DEFAULTGATEWAY => $gateway{'default/0.0.0.0'}
            })
    }

    for ( `lanscan -iap`) {
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

        if ( /^(\S+)\s(\S+)\s(\S+)\s+(\S+)/) {
            $macaddr=$1;
            $name=$2;
            $lanid=$4;
            if ( $macaddr =~ /^0x(..)(..)(..)(..)(..)(..)$/ ) { $macaddr = "$1:$2:$3:$4:$5:$6" }
            #print "name $name macaddr $macaddr lanid $lanid\n";
            for ( `lanadmin -g $lanid` ) {
                if (/Type.+=\s(.+)/) { $type = $1; }
                if (/Description\s+=\s(.+)/) { $description = $1; }
                if (/Speed.+=\s(\d+)/) {
                    $speed = ($1 > 1000000)? $1/1000000 : $1; # in old version speed was given in Mbps and we want speed in Mbps
                }
                if (/Operation Status.+=\sdown\W/i) { $status = "Down"; } #It is not the only criteria
            } # for lanadmin
            #print "name $name macaddr $macaddr lanid $lanid speed $speed status $status \n";
            for ( `ifconfig $name 2> /dev/null` ) {
                if ( not $status and /$name:\s+flags=.*\WUP\W/ ) { #Its status is not reported as down in lanadmin -g
                    $status = 'Up';
                }
                if ( /inet\s(\S+)\snetmask\s(\S+)\s/ ) {
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

            $ipgateway = $gateway{$ipsubnet.'/'.$ipmask};
            # replace the $ipaddress (ie IP Address of the interface itself) by the default gateway IP adress if it exists
            if (defined($ipgateway) and $ipgateway eq $ipaddress and defined($gateway{'default/0.0.0.0'})) {
                $ipgateway = $gateway{'default/0.0.0.0'}
            }

            #Some cleanups
            if ( $ipaddress eq '0.0.0.0' ) { $ipaddress = "" }
            if ( not $ipaddress and not $ipmask and $ipsubnet eq '0.0.0.0' ) { $ipsubnet = "" }
            if ( not $status ) { $status = 'Down' }

            $inventory->addNetwork({
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
            });
        } # If
    } # For lanscan
}

1;
