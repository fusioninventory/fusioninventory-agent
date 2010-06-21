package FusionInventory::Agent::Task::Inventory::OS::MacOS::Networks;

# I think I hijacked most of this from the BSD/Linux modules

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    can_run("ifconfig") && can_load("Net::IP qw(:PROC)")
}


sub _ipdhcp {
    my $if = shift;

    my $path;
    my $ipdhcp;
    my $leasepath;

    foreach ( # XXX BSD paths
        "/var/db/dhclient.leases.%s",
        "/var/db/dhclient.leases",
        # Linux path for some kFreeBSD based GNU system
        "/var/lib/dhcp3/dhclient.%s.leases",
        "/var/lib/dhcp3/dhclient.%s.leases",
        "/var/lib/dhcp/dhclient.leases") {

        $leasepath = sprintf($_,$if);
        last if (-e $leasepath);
    }
    return unless -e $leasepath;

    if (open my $handle, '<', $leasepath) {
        my $lease;
        my $dhcp;
        my $expire;
        # find the last lease for the interface with its expire date
        while(<$handle>){
            $lease = 1 if(/lease\s*{/i);
            $lease = 0 if(/^\s*}\s*$/);
            if ($lease) { #inside a lease section
                if(/interface\s+"(.+?)"\s*/){
                    $dhcp = ($1 =~ /^$if$/);
                }
                #Server IP
                if(/option\s+dhcp-server-identifier\s+(\d{1,3}(?:\.\d{1,3}){3})\s*;/
                        and $dhcp){
                    $ipdhcp = $1;
                }
                if (/^\s*expire\s*\d\s*(\d*)\/(\d*)\/(\d*)\s*(\d*):(\d*):(\d*)/
                        and $dhcp) {
                    $expire=sprintf "%04d%02d%02d%02d%02d%02d",$1,$2,$3,$4,$5,$6;
                }
            }
        }
        close $handle or warn;
        chomp (my $currenttime = `date +"%Y%m%d%H%M%S"`);
        undef $ipdhcp unless $currenttime <= $expire;
    } else {
        warn "Can't open $leasepath: $ERRNO";
    }
    return $ipdhcp;
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
        next unless(/^en(0|1)/); # darwin has a lot of interfaces, for this purpose we only want to deal with eth0 and eth1
        if (/^(\S+):/) { push @list , $1; } # new interface name
    }

    # for each interface get it's parameters
    foreach my $description (@list) {
        $ipaddress = $ipmask = $macaddr = $status =  $type = undef;
        # search interface infos
        @ifconfig = `ifconfig $description`;
        foreach (@ifconfig){
            $ipaddress = $1 if /inet (\S+)/i;
            $ipmask = $1 if /netmask\s+(\S+)/i;
            $macaddr = $2 if /(address:|ether|lladdr)\s+(\S+)/i;
            $status = 1 if /status:\s+active/i;
            $type = $1 if /media:\s+(\S+)/i;
        }
        my $binip = &ip_iptobin ($ipaddress ,4);
        # In BSD, netmask is given in hex form
        my $binmask = sprintf("%b", oct($ipmask));
        my $binsubnet = $binip & $binmask;
        $ipsubnet = ip_bintoip($binsubnet,4);
        my $mask = ip_bintoip($binmask,4);
        $inventory->addNetwork({
            DESCRIPTION => $description,
            IPADDRESS => ($status?$ipaddress:undef),
            IPDHCP => _ipdhcp($description),
            IPGATEWAY => ($status?$ipgateway:undef),
            IPMASK => ($status?$mask:undef),
            IPSUBNET => ($status?$ipsubnet:undef),
            MACADDR => $macaddr,
            STATUS => ($status?"Up":"Down"),
            TYPE => ($status?$type:undef)
        });
    }
}

1;
