package FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Regexp;

sub isInventoryEnabled {
    return 
        can_run('ifconfig') &&
        can_run('route') &&
        can_load("Net::IP");
}

# Initialise the distro entry
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $routes = _getRoutes();

    if ($routes->{'0.0.0.0'}) {
    $inventory->setHardware(
            DEFAULTGATEWAY => $routes->{'0.0.0.0'}
        );
    }

    my @interfaces = _getInterfaces($logger, $routes);
    foreach my $interface (@interfaces) {
        $inventory->addNetwork($interface);
    }

    # add all ip addresses found, excepted loopback, to hardware
    my @ip_addresses =
        grep { ! /^127/ }
        grep { $_ }
        map { $_->{IPADDRESS} }
        @interfaces;

    $inventory->setHardware(
        IPADDR => join('/', @ip_addresses)
    );
}

sub _getRoutes {

    my $routes;
    foreach my $line (`route -n`) {
        next unless $line =~ /^($ip_address_pattern) \s+ ($ip_address_pattern)/x;
        $routes->{$1} = $2;
    }
    return $routes;
}

sub _getInterfaces {
    my ($logger, $routes) = @_;

    my @interfaces = _parseIfconfig('/sbin/ifconfig -a', '-|');

    foreach my $interface (@interfaces) {
        if (_isWifi($interface->{DESCRIPTION})) {
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
            $interface->{DESCRIPTION},
            $interface
        );

        $interface->{IPDHCP} = getIpDhcp($logger, $interface->{DESCRIPTION});
        $interface->{SLAVES} = _getSlaves($interface->{DESCRIPTION});
    }

    return @interfaces;
}

sub _parseIfconfig {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

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
    my ($name, $pcislot) = @_;

    my $virtualdev;

    if (-d "/sys/devices/virtual/net/") {
        $virtualdev = -d "/sys/devices/virtual/net/$name" ? 1 : 0;
    } else {
        if (can_run('brctl')) {
            # Let's guess
            my %bridge;
            foreach (`brctl show`) {
                next if /^bridge name/;
                $bridge{$1} = 1 if /^(\w+)\s/;
            }
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
    my ($name) = @_;

    my @wifistatus = `/sbin/iwconfig $name 2>/dev/null`;
    return @wifistatus > 2;
}

sub _getUevent {
    my ($logger, $name) = @_;

    my ($driver, $pcislot);

    my $file = "/sys/class/net/$name/device/uevent";
    if (-r $file) {
        if (open my $handle, '<', $file) {
            while (<$handle>) {
                $driver = $1 if /^DRIVER=(\S+)/;
                $pcislot = $1 if /^PCI_SLOT_NAME=(\S+)/;
            }
            close $handle;
        } else {
            $logger->warn("Can't open $file: $ERRNO");
        }
    }

    return ($driver, $pcislot);
}

sub _getNetworkInfo {
    my ($address, $mask, $routes) = @_;

    # import Net::IP functional interface
    Net::IP->import(':PROC');

    my ($ipsubnet, $ipgateway);

    my $binip = ip_iptobin($address, 4);
    my $binmask = ip_iptobin($mask, 4);
    my $binsubnet = $binip & $binmask;

    $ipsubnet = ip_bintoip($binsubnet, 4);
    $ipgateway = $routes->{$ipsubnet};

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

1;
