package FusionInventory::Agent::Task::Inventory::OS::BSD::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run("ifconfig") && 
        can_load("Net::IP");
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    # import Net::IP functional interface
    Net::IP->import(':PROC');

    my $description;
    my $ipaddress;
    my $ipgateway;
    my $ipmask;
    my $ipsubnet;
    my $macaddr;
    my $status;
    my $type;
    my $mtu;
    my $virtualdev;


    # Looking for the gateway
    # 'route show' doesn't work on FreeBSD so we use netstat
    # XXX IPV4 only
    for(`netstat -nr -f inet`){
        $ipgateway=$1 if /^default\s+(\S+)/i;
    }

    my @ifconfig = `ifconfig -a`; # -a option required on *BSD


    # first make the list available interfaces
    # too bad there's no -l option on OpenBSD
    my @list;
    foreach (@ifconfig){
        # skip loopback, pseudo-devices and point-to-point interfaces
        next if /^(fwe|sit|pflog|pfsync|enc|strip|plip|sl|ppp)\d+/;
        if (/^(\S+):/) { push @list , $1; } # new interface name	  
    }

    # for each interface get it's parameters
    foreach my $description (@list) {
        $ipaddress = $ipmask = $macaddr = $status =  $type = $mtu = "";
        $virtualdev = undef;
        # search interface infos
        @ifconfig = `ifconfig $description`;
        foreach (@ifconfig){
            $ipaddress = $1 if /inet (\S+)/i;
            $ipmask = $1 if /netmask\s+(\S+)/i;
            $macaddr = $2 if /(address:|ether|lladdr)\s+(\S+)/i;
            $status = 1 if /<UP/i;
            $type = $1 if /media:\s+(\S+)/i;
            $mtu = $1 if /mtu\s+(\S+)/i;
        }

        my $binip = &ip_iptobin ($ipaddress ,4);
        # In BSD, netmask is given in hex form
        my $binmask = sprintf("%b", oct($ipmask));
        my $binsubnet = $binip & $binmask;
        $ipsubnet = ip_bintoip($binsubnet,4);

        if ($ipmask =~ /^0x(\w{2})(\w{2})(\w{2})(\w{2})$/) {
             $ipmask = hex($1).'.'.hex($2).'.'.hex($3).'.'.hex($4);
        }

        $_ = $description;
        if (/^(lo|vboxnet|vmnet|tun)\d+/) {
            $virtualdev = 1;
        }

        $inventory->addNetwork({
            DESCRIPTION => $description,
            IPADDRESS => $ipaddress,
            IPDHCP => getIpDhcp($logger, $description),
            IPGATEWAY => ($status?$ipgateway:undef),
            IPMASK => $ipmask,
            IPSUBNET => ($status?$ipsubnet:undef),
            MACADDR => $macaddr,
            STATUS => $status?"Up":"Down",
            TYPE => $type,
            MTU => $mtu,
            VIRTUALDEV => $virtualdev
        });
    }
}

1;
