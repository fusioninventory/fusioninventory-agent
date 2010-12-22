package FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

#ce5: flags=1000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4> mtu 1500 index 3
#        inet 55.37.101.171 netmask fffffc00 broadcast 55.37.103.255
#        ether 0:3:ba:24:9b:bf

#aggr40001:2: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 3
#        inet 55.37.101.172 netmask ffffff00 broadcast 223.0.146.255
#NDD=/usr/sbin/ndd
#KSTAT=/usr/bin/kstat
#IFC=/sbin/ifconfig
#DLADM=/usr/sbin/dladm

sub isInventoryEnabled {
    return 
        can_run('ifconfig') &&
        can_run('netstat');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # set list of network interfaces
    my $routes = _getRoutes();
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
        IPADDR         => join('/', @ip_addresses),
        DEFAULTGATEWAY => $routes->{default}
    );
}

sub _getRoutes {

    my $routes;
    foreach my $line (`netstat -nr -f inet`) {
        next unless $line =~ /^default\s+(\S+)/i;
        $routes->{default} = $1;
    }

    return $routes;
}

sub _getInterfaces {

    # import Net::IP functional interface
    Net::IP->import(':PROC');

    my $description;
    my $ipaddress;
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

    if ($OSLevel =~ /5.8/ ){
        $zone = "global";
    } else {
        foreach (`zoneadm list -p`){
            $zone = $1 if /^0:([a-z]+):.*$/;
        }
    }

    my @interfaces = _parseIfconfig($zone);

    return @interfaces unless $zone;

    if ($OSLevel =~ /5.10/) {
        foreach (`/usr/sbin/dladm show-aggr`){
            next if /device/;
            next if /key/;
            $description = $1 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/; # aggrega
            $macaddr = $2 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
            $speed = $3." ".$4." ".$5 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
            $status = 1 if /up/;
            $ipaddress = "0.0.0.0";
            push @interfaces, {
                DESCRIPTION => $description,
                IPADDRESS => $ipaddress,
                IPMASK => $ipmask,
                IPSUBNET => $ipsubnet,
                MACADDR => $macaddr,
                STATUS => $status?"Up":"Down",
                SPEED => $speed,
                TYPE => $type,
            };
        }

        $ipsubnet = $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

        my $inc = 1;
        foreach (`/usr/sbin/fcinfo hba-port`) {
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

            if ($description &&  $macaddr) {
                push @interfaces, {
                    DESCRIPTION => $description,
                    IPADDRESS => $ipaddress,
                    IPMASK => $ipmask,
                    IPSUBNET => $ipsubnet,
                    MACADDR => $macaddr,
                    STATUS => $status?"Up":"Down",
                    SPEED => $speed,
                    TYPE => $type,
                };
                $inc ++ ;

                $ipsubnet = $ipaddress = $description = $macaddr = $status =  $speed = $type = $ipmask = undef;
            }
        }
    }

    return @interfaces;
}

# Function to test Quad Fast-Ethernet, Fast-Ethernet, and
# Gigabit-Ethernet (i.e. qfe_, hme_, ge_, fjgi_)
sub _check_nic {
    my ($mynic, $mynum) = @_;

    my ($speed, $duplex, $auto);

    foreach (`/usr/sbin/ndd -get /dev/$mynic link_speed`) {
        next unless /^(\d+)/;
        $speed = $1;
        last;
    }
    foreach (`/usr/sbin/ndd -get /dev/$mynic link_mode`) {
        next unless /^(\d+)/;
        $duplex = $1;
        last;
    }
    my $arg = $mynic =~ /ge/ ? 'adv_1000autoneg_cap' : 'adv_autoneg_cap';
    foreach (`/usr/sbin/ndd -get /dev/$mynic $arg`) {
        next unless /^(\d+)/;
        $auto = $1;
        last;
    }

    return _get_link_info($speed, $duplex, $auto);
}

# Function to test eri Fast-Ethernet (eri_).
sub _check_eri {
    my ($mynic, $mynum) = @_;

    my ($speed, $duplex, $auto);
    foreach (`/usr/sbin/ndd -get /dev/$mynic link_speed`) {
        next unless /^(\d+)/;
        $speed = $1;
        last;
    }
    foreach (`/usr/sbin/ndd -get /dev/$mynic link_mode`) {
        next unless /^(\d+)/;
        $duplex = $1;
        last;
    }

    return _get_link_info($speed, $duplex, $auto);
}

# Function to test a Gigabit-Ethernet (i.e. ce_).
# Function to test a Intel 82571-based ethernet controller port (i.e. ipge_).
sub _check_ce {
    my ($mynic, $mynum) = @_;

    my ($speed, $duplex, $auto);

    foreach (`/usr/bin/kstat -m $mynic -i $mynum -s link_speed`) {
        next unless /^\s*link_speed+\s*(\d+).*$/;
        $speed = $1;
        last;
    }
    foreach (`/usr/bin/kstat -m $mynic -i $mynum -s link_duplex`) {
        next unless /^\s*link_duplex+\s*(\d+).*$/;
        $duplex = $1;
        last;
    }
    foreach (`/usr/bin/kstat -m $mynic -i $mynum -s cap_autoneg`) {
        next unless /^\s*cap_autoneg+\s*(\d+).*$/;
        $auto = $1;
        last;
    }

    return _get_link_info($speed, $duplex, $auto);

}

# Function to test Sun BGE interface on Sun Fire V210 and V240.
# The BGE is a Broadcom BCM5704 chipset. There are four interfaces
# on the V210 and V240. (i.e. bge_)
sub _check_bge_nic {
    my ($mynic, $mynum) = @_;

    my ($speed, $duplex, $auto);

    foreach (`/usr/sbin/ndd -get /dev/$mynic$mynum link_speed`) {
        next unless /^(\d+)/;
        $speed = $1;
        last;
    }
    foreach (`/usr/sbin/ndd -get /dev/$mynic$mynum link_duplex`) {
        next unless /^(\d+)/;
        $duplex = $1;
        last;
    }
    foreach (`/usr/sbin/ndd -get /dev/$mynic$mynum adv_autoneg_cap`) {
        next unless /^(\d+)/;
        $auto = $1;
        last;
    }

    return _get_link_info($speed, $duplex, $auto);
}


# Function to test Sun NXGE interface on Sun Fire Tx000.
sub _check_nxge_nic {
    my ($mynic, $mynum) = @_;

    my $link_info;
    foreach (`/usr/sbin/dladm show-dev $mynic$mynum`) {
        #nxge0           link: up        speed: 1000  Mbps       duplex: full
        $link_info = $5." ".$6." ".$8 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
    }
    return $link_info;
}

sub _check_dmf_nic {
}

sub _get_link_info {
    my ($speed, $duplex, $auto) = @_;

    my $info;

    $info =
        $speed == 0    ? "10 Mb/s"  :
        $speed == 10   ? "10 Mb/s"  :
        $speed == 100  ? "100 Mb/s" :
        $speed == 1000 ? "1 Gb/s"   :
                         "ERROR"    ;

    $info .=
        $duplex == 2 ? " FDX"     :
        $duplex == 1 ? " HDX"     :
        $duplex == 0 ? " UNKNOWN" :
                       " ERROR"   ;

    if ($auto) {
        $info .=
            $auto == 0 ? " AUTOSPEED ON"    :
            $auto == 1 ? " AUTOSPEED OFF"   :
                         " ERROR"           ;
    }

    return $info;
}

sub _parseIfconfig {

    my @interfaces;
    my $interface;

    foreach (`ifconfig -a`) {

        if (/^(\S+):(\S+):/) {
            $interface->{DESCRIPTION} = $1 . ":" . $2;
        } elsif (/^(\S+):/) {
            $interface->{DESCRIPTION} = $1;
        }

        if (/inet\s+(\S+)/i) {
            $interface->{IPADDRESS} = $1;
        }

        if (/\S*netmask\s+(\S+)/i) {
            # hex to dec to bin to ip
            $interface->{IPMASK} = ip_bintoip(
                unpack("B*", pack("N", sprintf("%d", hex($1)))),
                4
            );
        }

        if (/groupname\s+(\S+)/i) {
            $interface->{TYPE} = $1;
        }

        if (/zone\s+(\S+)/) {
            $interface->{TYPE} = $1;
        }

        if (/ether\s+(\S+)/i) {
            # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
            $interface->{MACADDR} =
                sprintf "%02x:%02x:%02x:%02x:%02x:%02x" , map hex, split /\:/, $1;
        }

        if (/<UP,/) {
            $interface->{STATUS} = "Up";
        }

        if ($interface->{DESCRIPTION} && $interface->{MACADDR}) {
            my ($nic, $num);
            if ($interface->{DESCRIPTION} =~ /^(\S+)(\d+)/) {
                $nic = $1;
                $num = $2;
            }

            if ($nic =~ /bge/ ) {
                $interface->{SPEED} = _check_bge_nic($nic, $num);
            } elsif ($nic =~ /ce/) {
                $interface->{SPEED} = _check_ce($nic, $num);
            } elsif ($nic =~ /hme/) {
                $interface->{SPEED} = _check_nic($nic, $num);
            } elsif ($nic =~ /dmfe/) {
                $interface->{SPEED} = _check_dmf_nic($nic, $num);
            } elsif ($nic =~ /ipge/) {
                $interface->{SPEED} = _check_ce($nic, $num);
            } elsif ($nic =~ /e1000g/) {
                $interface->{SPEED} = _check_ce($nic, $num);
            } elsif ($nic =~ /nxge/) {
                $interface->{SPEED} = _check_nxge_nic($nic, $num);
            } elsif ($nic =~ /eri/) {
                $interface->{SPEED} = _check_nic($nic, $num);
            } elsif ($nic =~ /aggr/) {
                $interface->{SPEED} = "";
            } else {
                $interface->{SPEED} = _check_nic($nic, $num);
            }

            $interface->{IPSUBNET} = getSubnetAddress(
                $interface->{IPADDRESS}, $interface->{IPMASK}
            );

            $interface->{STATUS} = 'Down' if !$interface->{STATUS};

            push @interfaces, $interface;
        }
    }

    return @interfaces;
}

1;
