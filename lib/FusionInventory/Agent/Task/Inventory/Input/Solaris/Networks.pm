package FusionInventory::Agent::Task::Inventory::Input::Solaris::Networks;

use strict;
use warnings;

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
use FusionInventory::Agent::Tools::Solaris;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return canRun('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes     = getRoutingTable(logger => $logger);
    my @interfaces = _getInterfaces(logger => $logger);

    foreach my $interface (@interfaces) {
        $interface->{IPGATEWAY} = $params{routes}->{$interface->{IPSUBNET}}
            if $interface->{IPSUBNET};

        $inventory->addEntry(
            section => 'NETWORKS',
            entry   => $interface
        );
    }

    $inventory->setHardware({
        DEFAULTGATEWAY => $routes->{'0.0.0.0'}
    });
}

sub _getInterfaces {
    my (%params) = @_;

    my @interfaces = _parseIfconfig(
        command => 'ifconfig -a',
        @_
    );

    foreach my $interface (@interfaces) {
        if ($interface->{DESCRIPTION} =~ /^(\S+)(\d+)/) {
            my $nic = $1;
            my $num = $2;

            $interface->{SPEED} =
                $nic =~ /aggr/   ? undef                       :
                $nic =~ /dmfe/   ? undef                       :
                $nic =~ /bge/    ? _check_bge_nic($nic, $num)  :
                $nic =~ /nxge/   ? _check_nxge_nic($nic, $num) :
                $nic =~ /ce/     ? _check_ce_nic($nic, $num)   :
                $nic =~ /ipge/   ? _check_ce_nic($nic, $num)   :
                $nic =~ /e1000g/ ? _check_ce_nic($nic, $num)   :
                                   _check_nic($nic, $num);
        }

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );
    }

    my $zone = getZone();
    my $OSLevel = getFirstLine(command => 'uname -r');

    if ($zone && $OSLevel && $OSLevel =~ /5.10/) {
        push @interfaces, _parseDladm(
            command => '/usr/sbin/dladm show-aggr',
            logger  => $params{logger}
        );

        push @interfaces, _parsefcinfo(
            command => '/usr/sbin/fcinfo hba-port',
            logger  => $params{logger}
        );
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

# Function to test a Gigabit-Ethernet (i.e. ce_).
# Function to test a Intel 82571-based ethernet controller port (i.e. ipge_).
sub _check_ce_nic {
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

    #nxge0           link: up        speed: 1000  Mbps       duplex: full
    my ($speed, $unit, $duplex) = getFirstMatch(
        command => "/usr/sbin/dladm show-dev $nic$num",
        pattern => qr/
            $nic$num \s+
            link:   \s \S+   \s+
            speed:  \s (\d+) \s+ (\S+) \s+
            duplex: \s (\S+)
        /x
    );
    return $speed . ' ' . $unit . ' ' . $duplex;
}

sub _get_link_info {
    my ($speed, $duplex, $auto) = @_;

    my $info;

    if ($speed) {
        $info =
            $speed == 0    ? "10 Mb/s"  :
            $speed == 10   ? "10 Mb/s"  :
            $speed == 100  ? "100 Mb/s" :
            $speed == 1000 ? "1 Gb/s"   :
                             "ERROR"    ;
    }

    if ($duplex) {
        $info .=
            $duplex == 2 ? " FDX"     :
            $duplex == 1 ? " HDX"     :
            $duplex == 0 ? " UNKNOWN" :
                           " ERROR"   ;
    }

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
            # new interface
            push @interfaces, $interface if $interface;
            # quick assertion: nothing else as ethernet interface
            $interface = {
                STATUS      => 'Down',
                DESCRIPTION => $1 . ':' . $2,
                TYPE        => 'ethernet'
            };
        } elsif ($line =~ /^(\S+):/) {
            # new interface
            push @interfaces, $interface if $interface;
            # quick assertion: nothing else as ethernet interface
            $interface = {
                STATUS      => 'Down',
                DESCRIPTION => $1,
                TYPE        => 'ethernet'
            };
        }

        if ($line =~ /inet ($ip_address_pattern)/) {
            $interface->{IPADDRESS} = $1;
        }
        if ($line =~ /netmask ($hex_ip_address_pattern)/i) {
            $interface->{IPMASK} = hex2canonical($1);
        }
        if ($line =~ /ether\s+(\S+)/i) {
            # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
            $interface->{MACADDR} =
                sprintf "%02x:%02x:%02x:%02x:%02x:%02x" , map hex, split /\:/, $1;
        }
        if ($line =~ /<UP,/) {
            $interface->{STATUS} = "Up";
        }
    }
    close $handle;

    # last interface
    push @interfaces, $interface if $interface;

    return @interfaces;
}

sub _parseDladm {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    while (my $line = <$handle>) {
        next if $line =~ /device/;
        next if $line =~ /key/;
        my $interface = {
            STATUS    => 'Down',
            IPADDRESS => "0.0.0.0",
        };
        next unless
            $line =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
        $interface->{DESCRIPTION} = $1;
        $interface->{MACADDR}     = $2;
        $interface->{SPEED}       = $3 . " " . $4 . " " . $5;
        $interface->{STATUS}      = 'Up' if $line =~ /UP/;
        push @interfaces, $interface;
    }
    close $handle;

    return @interfaces;
}

sub _parsefcinfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $inc = 1;
    my $interface;
    while (my $line = <$handle>) {
        $interface->{DESCRIPTION} = "HBA_Port_WWN_" . $inc if $line =~ /HBA Port WWN:\s+(\S+)/;
        $interface->{DESCRIPTION} .= " " . $1 if $line =~ /OS Device Name:\s+(\S+)/;
        $interface->{SPEED} = $1 if $line =~ /Current Speed:\s+(\S+)/;
        $interface->{WWN} = $1 if $line =~ /Node WWN:\s+(\S+)/;
        $interface->{DRIVER} = $1 if $line =~ /Driver Name:\s+(\S+)/i;
        $interface->{MANUFACTURER} = $1 if $line =~ /Manufacturer:\s+(.*)$/;
        $interface->{MODEL} = $1 if $line =~ /Model:\s+(.*)$/;
        $interface->{FIRMWARE} = $1 if $line =~ /Firmware Version:\s+(.*)$/;
        $interface->{STATUS} = 'Up' if $line =~ /online/;

        if ($interface->{DESCRIPTION} && $interface->{WWN}) {
            $interface->{STATUS} = 'Down' if !$interface->{STATUS};

            push @interfaces, $interface;
            $interface = {};
            $inc++;
        }
    }
    close $handle;

    return @interfaces;
}

1;
