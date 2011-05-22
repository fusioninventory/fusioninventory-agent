package FusionInventory::Agent::Task::Inventory::OS::Linux::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 
        can_run('ifconfig') &&
        can_run('route');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes = _getRoutes($logger);
    my @interfaces = _getInterfaces($logger, $routes);
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
        DEFAULTGATEWAY => $routes->{'0.0.0.0'}
    });
}

sub _getRoutes {
    my ($logger) = @_;

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'route -n'
    );

    return unless $handle;

    my $routes;
    while (my $line = <$handle>) {
        next unless $line =~ /^($ip_address_pattern) \s+ ($ip_address_pattern)/x;
        $routes->{$1} = $2;
    }
    close $handle;

    return $routes;
}

sub _getInterfaces {
    my ($logger, $routes) = @_;

    my @interfaces = can_run("/sbin/ip") ?
        _parseIpAddrShow(command => '/sbin/ip addr show', logger => $logger):
        _parseIfconfig(command => '/sbin/ifconfig -a',    logger => $logger);

    foreach my $interface (@interfaces) {
        if (_isWifi($logger, $interface->{DESCRIPTION})) {
            $interface->{TYPE} = "Wifi";
        }

        if ($interface->{IPADDRESS} && $interface->{IPMASK}) {
            my ($ipsubnet, $ipgateway) = _getNetworkInfo(
                $interface->{IPADDRESS},
                $interface->{IPMASK},
                $routes
            );
            $interface->{IPSUBNET} = $ipsubnet;
            $interface->{IPGATEWAY} = $ipgateway;
        }

        my ($driver, $pcislot) = _getUevent(
            $logger,
            $interface->{DESCRIPTION}
        );
        $interface->{DRIVER} = $driver if $driver;
        $interface->{PCISLOT} = $pcislot if $pcislot;

        $interface->{VIRTUALDEV} = _getVirtualDev(
            $logger,
            $interface->{DESCRIPTION},
            $interface
        );

        $interface->{IPDHCP} = getIpDhcp($logger, $interface->{DESCRIPTION});
        $interface->{SLAVES} = _getSlaves($interface->{DESCRIPTION});
    }

    return @interfaces;
}

sub _parseIfconfig {

    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;

    my $interface = { STATUS => 'Down' };

    while (my $line = <$handle>) {
        if ($line =~ /^$/) {
            # end of interface section
            next unless $interface->{DESCRIPTION};

            push @interfaces, $interface;

            $interface = { STATUS => 'Down' };

        } else {
            # In a section
            if ($line =~ /^(\S+)/) {
                $interface->{DESCRIPTION} = $1;
            }
            if ($line =~ /inet addr:($ip_address_pattern)/i) {
                $interface->{IPADDRESS} = $1;
            }
            if ($line =~ /mask:(\S+)/i) {
                $interface->{IPMASK} = $1;
            }
            if ($line =~ /inet6 addr: (\S+)/i) {
                $interface->{IPADDRESS6} = $1;
            }
            if ($line =~ /hwadd?r\s+($mac_address_pattern)/i) {
                $interface->{MACADDR} = $1;
            }
            if ($line =~ /^\s+UP\s/) {
                $interface->{STATUS} = 'Up';
            }
            if ($line =~ /link encap:(\S+)/i) {
                $interface->{TYPE} = $1;
            }
        }

    }
    close $handle;

    return @interfaces;
}

# Handle slave devices (bonding)
sub _getSlaves {
    my ($name) = @_;

    my @slaves = ();
    while (my $slave = glob("/sys/class/net/$name/slave_*")) {
        if ($slave =~ /\/slave_(\w+)/) {
            push(@slaves, $1);
        }
    }

    return join (",", @slaves);
}

# Handle virtual devices (bridge)
sub _getVirtualDev {
    my ($logger, $name, $pcislot) = @_;

    my $virtualdev;

    if (-d "/sys/devices/virtual/net/") {
        $virtualdev = -d "/sys/devices/virtual/net/$name" ? 1 : 0;
    } else {
        if (can_run('brctl')) {
            # Let's guess
            my %bridge;
            my $handle = getFileHandle(
                logger => $logger,
                command => 'brctl show'
            );
            my $line = <$handle>;
            while (my $line = <$handle>) {
                next unless $line =~ /^(\w+)\s/;
                $bridge{$1} = 1;
            }
            close $handle;
            if ($pcislot) {
                $virtualdev = "0";
            } elsif ($bridge{$name}) {
                $virtualdev = "1";
            }
        }
    }

    return $virtualdev;
}

sub _isWifi {
    my ($logger, $name) = @_;

    my $count = getLinesCount(
        logger  => $logger,
        command => "/sbin/iwconfig $name"
    );
    return $count > 2;
}

sub _getUevent {
    my ($logger, $name) = @_;

    my $file = "/sys/class/net/$name/device/uevent";
    my $handle = getFileHandle(file => $file);
    return unless $handle;

    my ($driver, $pcislot);
    while (<$handle>) {
        $driver = $1 if /^DRIVER=(\S+)/;
        $pcislot = $1 if /^PCI_SLOT_NAME=(\S+)/;
    }
    close $handle;

    return ($driver, $pcislot);
}

sub _getNetworkInfo {
    my ($address, $mask, $routes) = @_;

    my $ipsubnet = getSubnetAddress($address, $mask);
    my $ipgateway = $routes->{$ipsubnet};

    # replace '0.0.0.0' (ie 'default gateway') by the
    # default gateway IP adress if it exists
    if ($ipgateway and
        $ipgateway eq '0.0.0.0' and 
        $routes->{'0.0.0.0'}
    ) {
        $ipgateway = $routes->{'0.0.0.0'}
    }

    return ($ipsubnet, $ipgateway);
}

# Move in Tools.pm
# compute network IP and mask from the IP prefix.
# We should use it to drop the Net::IP::ip_iptobin() dependency.
sub _computeIPv4Network {
    my ($ip, $prefix) = @_;

    my $net = sprintf ("%08b%08b%08b%08b", split(/\./, $ip));
    my $mask;
    $net =~ s/^(.{$prefix})[0-1]*/$1/;
    $net .= sprintf("%0".(32-$prefix)."b", 0);
    $mask .= 1 foreach(1..$prefix);
    $mask .= 0 foreach(1..(32-$prefix));

    my $r = { network => undef, mask => undef };
    if ($net =~ /^(\d{8})(\d{8})(\d{8})(\d{8})$/) {
         $r->{network} =  oct("0b".$1).".".oct("0b".$2).".".oct("0b".$3).".".oct("0b".$4);
    }
    if ($mask =~ /^(\d{8})(\d{8})(\d{8})(\d{8})$/) {
         $r->{mask} =  oct("0b".$1).".".oct("0b".$2).".".oct("0b".$3).".".oct("0b".$4);
    }
    return $r;
}

# http://forge.fusioninventory.org/issues/854
sub _parseIpAddrShow {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @entries;
    my $entry;
    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ /^\d+:\s+(\S+): .*(UP|DOWN)/) {
            push @entries, $entry if $entry;
            $entry = {};
            $entry->{DESCRIPTION} = $1;
            $entry->{STATUS} = ucfirst(lc($2));
        } elsif ($line =~ /link\/ether ($mac_address_pattern)/) {
            $entry->{MACADDR} = $1;
        } elsif ($line =~ /inet6 (\S+)\//) {
            $entry->{IPADDRESS6} = $1;
        } elsif ($line =~ /inet ($ip_address_pattern)\/(\d{1,3})/) {
            $entry->{IPADDRESS} = $1;
            my $infoNet = _computeIPv4Network($1, $2);
            $entry->{IPSUBNET} = $infoNet->{network};
            $entry->{IPMASK} = $infoNet->{mask};
        }
    }

    return @entries;
}

1;
