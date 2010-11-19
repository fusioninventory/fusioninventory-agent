package FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks;


#ce5: flags=1000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4> mtu 1500 index 3
#        inet 55.37.101.171 netmask fffffc00 broadcast 55.37.103.255
#        ether 0:3:ba:24:9b:bf

#aggr40001:2: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 3
#        inet 55.37.101.172 netmask ffffff00 broadcast 223.0.146.255
#NDD=/usr/sbin/ndd
#KSTAT=/usr/bin/kstat
#IFC=/sbin/ifconfig
#DLADM=/usr/sbin/dladm

use strict;

sub isInventoryEnabled {
    can_run("ifconfig") && can_run("netstat") && can_load ("Net::IP qw(:PROC)")
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
    my $speed;
    my $type;
    my $nic;
    my $num;
    my $link_speed;
    my $link_duplex;
    my $link_info;
    my $link_auto;
    my $zone;
    my $OSLevel;
    my $i = 0;

    $OSLevel=`uname -r`;


# Function to test Quad Fast-Ethernet, Fast-Ethernet, and
# Gigabit-Ethernet (i.e. qfe_, hme_, ge_, fjgi_)

    sub check_nic {
        my ($mynic,$mynum) = @_;
        $link_info = undef;
        foreach (`/usr/sbin/ndd -get /dev/$mynic link_speed `){
            $link_speed = $1 if /^(\d+)/;
            if ($link_speed =~ /^0$/ ) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^1$/) {
                $link_info = $link_info."100 Mb/s";
            }elsif ($link_speed =~ /^1000$/) {
                $link_info = $link_info."1 Gb/s";
            }else {
                $link_info = $link_info."ERROR";
            }
        }

        foreach (`/usr/sbin/ndd -get /dev/$mynic link_mode `){
            $link_duplex = $1 if /^(\d+)/;
            if ($link_duplex =~ /1/ ) {
                $link_info = $link_info." FDX";
            }elsif ($link_duplex =~ /0/) {
                $link_info = $link_info." HDX";
            }else {
                $link_info = $link_info." ERROR";
            }
        }

        if ($mynic =~ /ge/){
            foreach (`/usr/sbin/ndd -get /dev/$mynic adv_1000autoneg_cap `){
                $link_auto = $1 if /^(\d+)/;
                if ($link_auto =~ /1/ ) {
                    $link_info = $link_info." AUTOSPEED ON";
                }elsif ($link_auto =~ /0/) {
                    $link_info = $link_info." AUTOSPEED OFF ";
                }else {
                    $link_info = $link_info." AUTOSPEED ERROR";
                }
            }
        }else{
            foreach (`/usr/sbin/ndd -get /dev/$mynic adv_autoneg_cap `){
                $link_auto = $1 if /^(\d+)/;
                if ($link_auto =~ /1/ ) {
                    $link_info = $link_info." AUTOSPEED ON";
                }elsif ($link_auto =~ /0/) {
                    $link_info = $link_info." AUTOSPEED OFF ";
                }else {
                    $link_info = $link_info." AUTOSPEED ERROR";
                }
            }
        }
        return $link_info;
    }

# Function to test eri Fast-Ethernet (eri_).
    sub check_eri {
        my ($mynic,$mynum) = @_;
        $link_info = undef;
        foreach (`/usr/sbin/ndd -get /dev/$mynic link_speed `){
            $link_speed = $1 if /^(\d+)/;
            if ($link_speed =~ /^0$/ ) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^1$/) {
                $link_info = $link_info."100 Mb/s";
            }elsif ($link_speed =~ /^1000$/) {
                $link_info = $link_info."1 Gb/s";
            }else {
                $link_info = $link_info."ERROR";
            }
        }
        foreach (`/usr/sbin/ndd -get /dev/$mynic link_mode `){
            $link_duplex = $1 if /^(\d+)/;
            if ($link_duplex =~ /1/ ) {
                $link_info = $link_info." FDX";
            }elsif ($link_duplex =~ /0/) {
                $link_info = $link_info." HDX";
            }else {
                $link_info = $link_info." ERROR";
            }
        }
        return $link_info;
    }



# Function to test a Gigabit-Ethernet (i.e. ce_).
# Function to test a Intel 82571-based ethernet controller port (i.e. ipge_).
    sub check_ce {
        my ($mynic,$mynum) = @_;
        $link_info = undef;
        foreach (`/usr/bin/kstat -m $mynic -i $mynum -s link_speed`){
            next unless /^\s*link_speed+\s*(\d+).*$/;
            $link_speed = $1;
            #print "SPEED = ".$link_speed."\n";
            if ($link_speed =~ /^0$/ ) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^10$/) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^100$/) {
                $link_info = $link_info."100 Mb/s";
            }elsif ($link_speed =~ /^1000$/) {
                $link_info = $link_info."1 Gb/s";
            }else {
                $link_info = $link_info."ERROR";
            }
        }
        foreach (`/usr/bin/kstat -m $mynic -i $mynum -s link_duplex`){
            next unless /^\s*link_duplex+\s*(\d+).*$/;
            $link_duplex = $1;
            if ($link_duplex =~ /2/ ) {
                $link_info = $link_info." FDX";
            }elsif ($link_duplex =~ /1/) {
                $link_info = $link_info." HDX";
            }elsif ($link_duplex =~ /0/) {
                $link_info = $link_info." UNKNOWN";
            }else {
                $link_info = $link_info." ERROR";
            }
        }

        foreach (`/usr/bin/kstat -m $mynic -i $mynum -s cap_autoneg`){
            next unless /^\s*cap_autoneg+\s*(\d+).*$/;
            $link_auto = $1;
            if ($link_auto =~ /1/ ) {
                $link_info = $link_info." AUTOSPEED ON";
            }elsif ($link_auto =~ /0/) {
                $link_info = $link_info." AUTOSPEED OFF ";
            }else {
                $link_info = $link_info." AUTOSPEED ERROR";
            }
        }

        return $link_info;
    }

# Function to test Sun BGE interface on Sun Fire V210 and V240.
# The BGE is a Broadcom BCM5704 chipset. There are four interfaces
# on the V210 and V240. (i.e. bge_)
    sub check_bge_nic {
        my ($mynic,$mynum) = @_;
        $link_info = undef;
        foreach (`/usr/sbin/ndd -get /dev/$mynic$mynum link_speed `){
            $link_speed = $1 if /^(\d+)/;
            if ($link_speed =~ /^0$/ ) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^10$/) {
                $link_info = $link_info."10 Mb/s";
            }elsif ($link_speed =~ /^100$/) {
                $link_info = $link_info."100 Mb/s";
            }elsif ($link_speed =~ /^1000$/) {
                $link_info = $link_info."1 Gb/s";
            }else {
                $link_info = $link_info."ERROR";
            }
        }
        foreach (`/usr/sbin/ndd -get /dev/$mynic$mynum link_duplex `){
            $link_duplex = $1 if /^(\d+)/;
            if ($link_duplex =~ /2/ ) {
                $link_info = $link_info." FDX";
            }elsif ($link_duplex =~ /1/) {
                $link_info = $link_info." HDX";
            }elsif ($link_duplex =~ /0/) {
                $link_info = $link_info." UNKNOWN";
            }else {
                $link_info = $link_info." ERROR";
            }
        }

        foreach (`/usr/sbin/ndd -get /dev/${1}${2} adv_autoneg_cap`){
            $link_auto = $1 if /^(\d+)/;
            if ($link_auto =~ /^0$/ ) {
                $link_info = $link_info."AUTOSPEED ON";
            }elsif ($link_auto =~ /1/) {
                $link_info = $link_info."AUTOSPEED OFF";
            }else {
                $link_info = $link_info."AUTOSPEED ERROR";
            }

        }
        return $link_info;
    }


    sub check_e1kg {



    }

# Function to test Sun NXGE interface on Sun Fire Tx000.
    sub check_nxge_nic {
        my ($mynic,$mynum) = @_;
        $link_info = undef;
        foreach (`/usr/sbin/dladm show-dev $mynic$mynum  `){
            #nxge0           link: up        speed: 1000  Mbps       duplex: full
            $link_info = $5." ".$6." ".$8 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
        }
        return $link_info;
    }

    sub check_dmf_nic {

    }

    if ( $OSLevel =~ /5.8/ ){
        $zone = "global";
    }else{
        foreach (`zoneadm list -p`){
            $zone=$1 if /^0:([a-z]+):.*$/;
        }
    }

    foreach (`netstat -rn`){
        $ipgateway=$1 if /^default\s+(\S+)/i;
    }
    #print "Nom :".$zone."*************************\n";
    if ($zone){
        foreach (`ifconfig -a`){
            $description = $1 if /^(\S+):/; # Interface name
            $ipaddress = $1 if /inet\s+(\S+)/i;
            $ipmask = $1 if /\S*netmask\s+(\S+)/i;
            $type = $1 if /groupname\s+(\S+)/i;
            #$type = $1 if /zone\s+(\S+)/i;
            #Debug
            if (/ether\s+(\S+)/i) {
                # See
                # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
                $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                map hex, split /\:/, $1;
            }
            $status = 1 if /<UP,/;
            #print "DES:".$description."-".$macaddr."-".$nic."-".$num."\n";
            if(($description && $macaddr)){
                $nic = $1 if ( $description =~ /^(\S+)(\d+)/);
                $num = $2 if ( $description =~/^(\S+)(\d+)/);
                #print "NIC ".$description." :".$nic."-".$num."\n";
                if ($nic =~ /bge/ ) {
                    $speed = check_bge_nic($nic,$num);
                }elsif ($nic =~ /ce/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /hme/) {
                    $speed = check_nic($nic,$num);
                }elsif ($nic =~ /dmfe/) {
                    $speed = check_dmf_nic($nic,$num);
                }elsif ($nic =~ /ipge/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /e1000g/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /nxge/) {
                    $speed = check_nxge_nic($nic,$num);
                }elsif ($nic =~ /eri/) {
                    $speed = check_nic($nic,$num);
                }elsif ($nic =~ /aggr/) {
                    $speed = "";
                }else {
                    $speed = check_nic($nic,$num);
                }
                #print "SPEED:".$speed ."\n";
                #HEX TO DEC TO BIN TO IP
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);

                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4);
                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        SPEED => $speed,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $speed = $description = $macaddr = $status =  $type = $ipmask = undef;
            }
        }
        $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

        foreach (`ifconfig -a`){
            $description = $1.":".$2 if /^(\S+):(\S+):/; # Interface name zone or virtual
            if ($description){
                $ipaddress = $1 if /inet\s+(\S+)/i;
                $ipmask = $1 if /\S*netmask\s+(\S+)/i;
                $status = 1 if /<UP,/;
                $type = $1 if /zone\s+(\S+)/i;
            }
            #Debug
            if(($description &&  $ipmask) ){
                #if(($description && $macaddr)){
                #HEX TO DEC TO BIN TO IP
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);
                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4);
                #print "INFO2 : ".$description."_". $ipaddress."_".$ipmask."_".$macaddr."\n";
                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;
            }
        }

        $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

        if ( $OSLevel =~ /5.10/ ){
            foreach (`/usr/sbin/dladm show-aggr`){
                next if /device/;
                next if /key/;
                $description = $1 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/; # aggrega
                $macaddr = $2 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
                $speed = $3." ".$4." ".$5 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
                #if ($macaddr) {
                #	  $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                #	  map hex, split /\:/, $1;
                #}
                #$status = $6 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
                $status = 1 if /up/;
                $ipaddress = "0.0.0.0";
                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        SPEED => $speed,
                        TYPE => $type,
                    });
            }

            $ipgateway = $ipsubnet = $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

            my $inc = 1 ;
            foreach (`/usr/sbin/fcinfo hba-port`){
                $description = "HBA_Port_WWN_".$inc if /HBA Port WWN:\s+(\S+)/;
                $description = $description." ".$1 if /OS Device Name:\s+(\S+)/;
                $speed = $1 if /Current Speed:\s+(\S+)/;
                $macaddr = $1 if /Node WWN:\s+(\S+)/;
                $type = $1 if /Manufacturer:\s+(.*)$/;
                $type = $type." ".$1 if /Model:\s+(.*)$/;
                $type = $type." ".$1 if /Firmware Version:\s+(.*)$/;
                $ipaddress = "0.0.0.0";
                #$ipaddress = "SN:".$1 if /Serial Number:\s+(\S+)/;
                $status = 1 if /online/;

                if(($description &&  $macaddr) ){
                    #print "WWN :".$description."-".$status."-".$type."-".$speed."\n";
                    $inventory->addNetwork({
                            DESCRIPTION => $description,
                            IPADDRESS => $ipaddress,
                            IPGATEWAY => $ipgateway,
                            IPMASK => $ipmask,
                            IPSUBNET => $ipsubnet,
                            MACADDR => $macaddr,
                            STATUS => $status?"Up":"Down",
                            SPEED => $speed,
                            TYPE => $type,
                        });
                    $inc ++ ;

                    $ipgateway = $ipsubnet = $ipaddress = $description = $macaddr = $status =  $speed = $type = $ipmask = undef;
                }
            }
        }

    }else {
        foreach (`ifconfig -a`){
            $description = $1.":".$2 if /^(\S+):(\S+):.*$/; # Interface name zone
            $ipaddress = $1 if /inet\s+(\S+)/i;
            $ipmask = $1 if /\S*netmask\s+(\S+)/i;
            $type = $1 if /zone\s+(\S+)/i;
            #Debug
            if (/ether\s+(\S+)/i) {
                # See
                # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
                $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                map hex, split /\:/, $1;
            }
            $status = 1 if /<UP,/;
            #print $description."_".$ipaddress."*****\n";
            if(($description &&  $ipaddress) ){
                $nic = $1 if ( $description =~ /^(\S+)(\d+):.*$/);
                $num = $2 if ( $description =~/^(\S+)(\d+):.*$/);
                #print "NIC ".$description." :".$nic."-".$num."\n";
                if ($nic =~ /bge/ ) {
                    $speed = check_bge_nic($nic,$num);
                }elsif ($nic =~ /ce/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /hme/) {
                    $speed = check_nic($nic,$num);
                }elsif ($nic =~ /dmfe/) {
                    $speed = check_dmf_nic($nic,$num);
                }elsif ($nic =~ /ipge/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /e1000g/) {
                    $speed = check_ce($nic,$num);
                }elsif ($nic =~ /nxge/) {
                    $speed = check_nxge_nic($nic,$num);
                }elsif ($nic =~ /eri/) {
                    $speed = check_nic($nic,$num);
                }else {
                    $speed = check_nic($nic,$num);
                }
                #print "SPEED:".$speed ."\n";
                #if(($description && $macaddr)){  zo
                #HEX TO DEC TO BIN TO IP
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);
                #print $ipmask."\n";

                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4);

                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        SPEED => $speed,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $speed = $description = $macaddr = $status =  $type = undef;
            }
        }

    }
}

1;
