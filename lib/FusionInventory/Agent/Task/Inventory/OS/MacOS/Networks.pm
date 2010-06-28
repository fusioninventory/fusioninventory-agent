package FusionInventory::Agent::Task::Inventory::OS::MacOS::Networks;

# I think I hijacked most of this from the BSD/Linux modules

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    can_run("ifconfig") && can_load("Net::IP qw(:PROC)")
}


# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $description;
    my $ipaddress;
    my $ipgateway;
    my $ipmask;
    my $ipsubnet;
    my $macaddr;
    my $status;
    my $type;


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
        #next if /^(lo|fwe|vmnet|sit|pflog|pfsync|enc|strip|plip|sl|ppp)\d+/;
#        next unless(/^en(0|1)/); # darwin has a lot of interfaces, for this purpose we only want to deal with eth0 and eth1
        if (/^(\S+):/) { push @list , $1; } # new interface name
    }

    # for each interface get it's parameters
    foreach my $description (@list) {
        my $ipaddress;
        my $ipmask;
        my $macaddr;
        my $status;
        my $type;
        my $binmask;
        my $binsubnet;
        my $mask;
        my $binip;
        my $virtualdev = 1;

        # search interface infos
        @ifconfig = `ifconfig $description`;
        foreach (@ifconfig){
            $ipaddress = $1 if /inet (\S+)/i;
            $ipmask = $1 if /netmask\s+(\S+)/i;
            $macaddr = $2 if /(address:|ether|lladdr)\s+(\S+)/i;
            $status = 1 if /status:\s+active/i;
            $type = $1 if /media:\s+(\S+)/i;
            $virtualdev = undef if /supported\smedia:/;
        }
        if ($status) {
            $binip = &ip_iptobin ($ipaddress ,4);
            # In BSD, netmask is given in hex form
            $binmask = sprintf("%b", oct($ipmask));
            $binsubnet = $binip & $binmask;
            $ipsubnet = ip_bintoip($binsubnet,4);
            $mask = ip_bintoip($binmask,4);
        }
        $inventory->addNetwork({
                DESCRIPTION => $description,
                IPADDRESS => $ipaddress,
                IPDHCP => undef,
                IPGATEWAY => $ipgateway,
                IPMASK => $mask,
                IPSUBNET => $ipsubnet,
                MACADDR => $macaddr,
                STATUS => ($status?"Up":"Down"),
                TYPE => $type,
                VIRTUALDEV => $virtualdev
            });
    }
}

1;
