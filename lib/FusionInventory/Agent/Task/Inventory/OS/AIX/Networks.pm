package FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

use strict;
use warnings;

sub isInventoryEnabled {
    can_load("Net::IP qw(:PROC)");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my %info;  

    my $ifname;
    foreach (`lscfg -v -l en*`) {
        $ifname = "en".$1 if /^\s+ent(\d+)\s+\S+\s+(.+)/;
        if ($ifname) {
            $info{$ifname}{type} = $2;
            $info{$ifname}{status} = "Down"; # default is down
            if (/Network Address\.+(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/) {
                $info{$ifname}{macaddr} = "$1:$2:$3:$4:$5:$6"
            }
        }
    } 

    # uncomment if you prefere verbose information about the link
    # e.g: 0xe8120000:0xe80c0000:741:3:512:1024:8192:Auto_Negotiation:2048:no:0x000000000000:10000:10:1000:yes:yes:no:no:yes:2048

    # etherchannel interfaces
    #my @lsdev=`lsdev -Cc adapter -s pseudo -t ibm_ech`;
#  foreach (`lsdev -Cc adapter`) {
#    next unless /^ent(\d*)\s*(\w*)\s*.*/;
#    my $ifname = "en".$1;
#    my $tmpifname = "ent".$1;
#    #@lsattr=`lsattr -EOl $1 -a 'adapter_names mode netaddr'`;
#    foreach (`lsattr -EOl $tmpifname`) {
#      if (/(.+):(.+):(.*)/) {
#	$info{$ifname}{type}="EtherChannel with : ".$1." (mode :".$2.", ping :".$3.")";
#      }
#    }
#    $info{$ifname}{status} = 'Down'; # The same
#  }

    foreach (split / /,`ifconfig -l`) {
        # AIX: network interface naming is enX
        if(/^(en\d+)/) {
            my $ifname = $1;
            foreach (`lsattr -E -l $ifname`) {
                $info{$ifname}{ip} = $1 if /^netaddr \s*([\d*\.?]*).*/i;
                $info{$ifname}{netmask} = $1 if /^netmask\s*([\d*\.?]*).*/i;
                $info{$ifname}{status} = $1 if /^state\s*(\w*).*/i; 
            } 
        }
    }

    #Looking for the gateways
    # AIX: the route command doesn't exist. We use netstat -rn instead
    foreach (`netstat -rn`) {
        if (/\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
            my $ifname = $2;
            my $gateway = $1;	

            if (exists ($info{$ifname})) { 
                $info{$ifname}{gateway} = $gateway;
            }
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
        $inventory->addNetwork({
            DESCRIPTION => $description,
            IPADDRESS => $ipaddress,
            IPDHCP => $ipdhcp,
            IPGATEWAY => $gateway,
            IPMASK => $ipmask,
            IPSUBNET => $ipsubnet,
            MACADDR => $macaddr,
            STATUS => $status,
            TYPE => $type,
        });		
    }
}

1;
