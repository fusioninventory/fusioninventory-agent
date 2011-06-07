package FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks;

use strict;
use warnings;

use Net::IP qw(:PROC);

#ce5: flags=1000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4> mtu 1500 index 3
#        inet 55.37.101.171 netmask fffffc00 broadcast 55.37.103.255
#        ether 0:3:ba:24:9b:bf

#aggr40001:2: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 3
#        inet 55.37.101.172 netmask ffffff00 broadcast 223.0.146.255
#NDD=/usr/sbin/ndd
#KSTAT=/usr/bin/kstat
#IFC=/sbin/ifconfig
#DLADM=/usr/sbin/dladm

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    return can_run('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes     = getRoutingTable(logger => $logger);
    my @interfaces = _getInterfaces(logger => $logger, routes => $routes);

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
        DEFAULTGATEWAY => $routes->{default}
    });
}

sub _getInterfaces {
    my (%params) = @_;

    my @interfaces = _parseIfconfig(
        command => '/sbin/ifconfig -a',
        logger  => $params{logger}
    );

    foreach my $interface (@interfaces) {
        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        if ($interface->{IPSUBNET}) {
            $interface->{IPGATEWAY} = $params{routes}->{$interface->{IPSUBNET}};
        }
    }

    my $zone = getZone();
    return @interfaces unless $zone;

    my $OSLevel = getFirstLine(command => 'uname -r');
    if ($OSLevel =~ /5.10/) {
        foreach (`/usr/sbin/dladm show-aggr`) {
            next if /device/;
            next if /key/;
            my $interface = {
                STATUS    => 'Down',
                IPADDRESS => "0.0.0.0",
            };
            $interface->{DESCRIPTION} = $1 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/; # aggrega
            $interface->{MACADDR} = $2 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
            $interface->{SPEED} = $3." ".$4." ".$5 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
            $interface->{STATUS} = 1 if /up/;
            push @interfaces, $interface;
        }

        my $inc = 1;
        my $interface;
        foreach (`/usr/sbin/fcinfo hba-port`) {
            $interface->{DESCRIPTION} = "HBA_Port_WWN_" . $inc if /HBA Port WWN:\s+(\S+)/;
            $interface->{DESCRIPTION} .= " " . $1 if /OS Device Name:\s+(\S+)/;
            $interface->{SPEED} = $1 if /Current Speed:\s+(\S+)/;
            $interface->{MACADDR} = $1 if /Node WWN:\s+(\S+)/;
            $interface->{TYPE} = $1 if /Manufacturer:\s+(.*)$/;
            $interface->{TYPE} .= " " . $1 if /Model:\s+(.*)$/;
            $interface->{TYPE} .= " " . $1 if /Firmware Version:\s+(.*)$/;
            $interface->{STATUS} = 1 if /online/;

            if ($interface->{DESCRIPTION} && $interface->{MACADDR}) {
                $interface->{IPADDRESS} = "0.0.0.0";
                $interface->{STATUS} = 'Down' if !$interface->{STATUS};

                push @interfaces, $interface;
                $inc++;
            }
        }
    }

    return @interfaces;
}

# Function to test Quad Fast-Ethernet, Fast-Ethernet, and
# Gigabit-Ethernet (i.e. qfe_, hme_, ge_, fjgi_)
sub _check_nic {
    my ($nic, $num) = @_;

    my $speed = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic link_speed",
        pattern => qr/^(\d+)/
    );

    my $duplex = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic link_mode",
        pattern => qr/^(\d+)/
    );

    my $arg = $nic =~ /ge/ ? 'adv_1000autoneg_cap' : 'adv_autoneg_cap';
    my $auto = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic $arg",
        pattern => qr/^(\d+)/
    );

    return _get_link_info($speed, $duplex, $auto);
}

# Function to test eri Fast-Ethernet (eri_).
sub _check_eri {
    my ($nic, $num) = @_;

    my $speed = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic link_speed",
        pattern => qr/^(\d+)/
    );

    my $duplex = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic link_mode",
        pattern => qr/^(\d+)/
    );

    return _get_link_info($speed, $duplex, undef);
}

# Function to test a Gigabit-Ethernet (i.e. ce_).
# Function to test a Intel 82571-based ethernet controller port (i.e. ipge_).
sub _check_ce {
    my ($nic, $num) = @_;

    my $speed = getFirstMatch(
        command => "/usr/bin/kstat -m $nic -i $num -s link_speed",
        pattern => qr/^\s*link_speed+\s*(\d+)/
    );

    my $duplex = getFirstMatch(
        command => "/usr/bin/kstat -m $nic -i $num -s link_duplex",
        pattern => qr/^\s*link_duplex+\s*(\d+)/
    );

    my $auto = getFirstMatch(
        command => "/usr/bin/kstat -m $nic -i $num -s cap_autoneg",
        pattern => qr/^\s*cap_autoneg+\s*(\d+)/
    );

    return _get_link_info($speed, $duplex, $auto);

}

# Function to test Sun BGE interface on Sun Fire V210 and V240.
# The BGE is a Broadcom BCM5704 chipset. There are four interfaces
# on the V210 and V240. (i.e. bge_)
sub _check_bge_nic {
    my ($nic, $num) = @_;

    my $speed = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic$num link_speed",
        pattern => qr/^(\d+)/
    );

    my $duplex = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic$num link_duplex",
        pattern => qr/^(\d+)/
    );

    my $auto = getFirstMatch(
        command => "/usr/sbin/ndd -get /dev/$nic$num adv_autoneg_cap",
        pattern => qr/^(\d+)/
    );

    return _get_link_info($speed, $duplex, $auto);
}


# Function to test Sun NXGE interface on Sun Fire Tx000.
sub _check_nxge_nic {
    my ($nic, $num) = @_;

    my $link_info;
    foreach (`/usr/sbin/dladm show-dev $nic$num`) {
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
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $interface;

    while (my $line = <$handle>) {
        if ($line =~ /^(\S+):(\S+):/) {
            $interface->{DESCRIPTION} = $1 . ":" . $2;
        } elsif ($line =~ /^(\S+):/) {
            $interface->{DESCRIPTION} = $1;
        }

        if ($line =~ /inet\s+(\S+)/i) {
            $interface->{IPADDRESS} = $1;
        }

        if ($line =~ /\S*netmask\s+(\S+)/i) {
            # hex to dec to bin to ip
            $interface->{IPMASK} = ip_bintoip(
                unpack("B*", pack("N", sprintf("%d", hex($1)))),
                4
            );
        }

        if ($line =~ /groupname\s+(\S+)/i) {
            $interface->{TYPE} = $1;
        }

        if ($line =~ /zone\s+(\S+)/) {
            $interface->{TYPE} = $1;
        }

        if ($line =~ /ether\s+(\S+)/i) {
            # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
            $interface->{MACADDR} =
                sprintf "%02x:%02x:%02x:%02x:%02x:%02x" , map hex, split /\:/, $1;
        }

        if ($line =~ /<UP,/) {
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
    close $handle;

    return @interfaces;
}

1;
