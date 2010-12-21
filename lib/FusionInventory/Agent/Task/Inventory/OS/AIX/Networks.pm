package FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_load("Net::IP");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my @interfaces = _getInterfaces();
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
        IPADDR => join('/', @ip_addresses)
    );
}

sub _getInterfaces {

    # import Net::IP functional interface
    Net::IP->import(':PROC');

    my %info;
    my @interfaces;

    foreach (`lscfg -v -l en*`) {
        next unless /^\s+ent(\d+)\s+\S+\s+(.+)/;
        my $ifname = "en".$1;
        $info{$ifname}{type} = $2;
        $info{$ifname}{status} = "Down"; # default is down
        if (/Network Address\.+(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/) {
            $info{$ifname}{macaddr} = "$1:$2:$3:$4:$5:$6"
        }
    } 

    foreach (split / /,`ifconfig -l`) {
        # network interface naming is enX
        next unless /^(en\d+)/;
        my $ifname = $1;
        foreach (`lsattr -E -l $ifname`) {
            $info{$ifname}{ip} = $1 if /^netaddr \s*([\d*\.?]*).*/i;
            $info{$ifname}{netmask} = $1 if /^netmask\s*([\d*\.?]*).*/i;
            $info{$ifname}{status} = $1 if /^state\s*(\w*).*/i; 
        } 
    }


    foreach my $ifname (sort keys %info) { 
        my $description = $ifname;
        my $type = $info{$ifname}{type};
        my $macaddr = $info{$ifname}{macaddr};
        my $status = $info{$ifname}{status};
        my $ipaddress = $info{$ifname}{ip};
        my $ipmask = $info{$ifname}{netmask};
        my $gateway = $info{$ifname}{gateway};
        my $ipdhcp = "No";
        my $ipsubnet;

        $status = "Down" unless $ipaddress;

        # Retrieving ip of the subnet for each interface
        if($ipmask and $ipaddress) {
            # To retrieve the subnet for this iface
            my $binip = &ip_iptobin ($ipaddress ,4);
            my $binmask = &ip_iptobin ($ipmask ,4);
            my $subnet = $binip & $binmask;
            $ipsubnet = ip_bintoip($subnet,4);
        }
        push @interfaces, {
            DESCRIPTION => $description,
            IPADDRESS => $ipaddress,
            IPDHCP => $ipdhcp,
            IPGATEWAY => $gateway,
            IPMASK => $ipmask,
            IPSUBNET => $ipsubnet,
            MACADDR => $macaddr,
            STATUS => $status,
            TYPE => $type,
        };
    }

    return @interfaces;
}

1;
