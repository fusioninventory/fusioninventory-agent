package FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        can_run("ifconfig") &&
        can_run("route") &&
        can_load("Net::IP");
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my %gateway;
    foreach (`route -n`) {
        if (/^(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/) {
            $gateway{$1} = $2;
        }
    }

    if ($gateway{'0.0.0.0'}) {
        $inventory->setHardware({
            DEFAULTGATEWAY => $gateway{'0.0.0.0'}
        });
    }

    my $interfaces = parseIfconfig('/sbin/ifconfig -a', '-|');

    foreach my $interface (@$interfaces) {
        if (isWifi($interface->{DESCRIPTION})) {
            $interface->{TYPE} = "Wifi";
        }

        if ($interface->{IPADDRESS} && $interface->{IPMASK}) {
            my ($ipsubnet, $ipgateway) = getNetworkInfo(
                $interface->{IPADDRESS},
                $interface->{IPMASK},
                \%gateway
            );
            $interface->{IPSUBNET} = $ipsubnet;
            $interface->{IPGATEWAY} = $ipgateway;
        }

        my ($driver, $pcislot) = getUevent($interface->{DESCRIPTION});
        $interface->{DRIVER} = $driver if $driver;
        $interface->{PCISLOT} = $pcislot if $pcislot;

        $interface->{VIRTUALDEV} = getVirtualDev(
            $interface->{DESCRIPTION},
            $interface
        );

        $interface->{IPDHCP} = getIpDhcp($interface->{DESCRIPTION});
        $interface->{SLAVES} = getSlaves($interface->{DESCRIPTION});

        $inventory->addNetwork($interface);
    }
}

sub parseIfconfig {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $interfaces;

    my $interface = { STATUS => 'Down' };

    while (my $line = <$handle>) {
        if ($line =~ /^$/) {
            # end of interface section
            next unless $interface->{DESCRIPTION};

            push @$interfaces, $interface;

            $interface = { STATUS => 'Down' };

        } else {
            # In a section
            if ($line =~ /^(\S+)/) {
                $interface->{DESCRIPTION} = $1;
            }
            if ($line =~ /inet addr:(\S+)/i) {
                $interface->{IPADDRESS} = $1;
            }
            if ($line =~ /mask:(\S+)/i) {
                $interface->{IPMASK} = $1;
            }
            if ($line =~ /hwadd?r\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/i) {
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

    return $interfaces;
}

# Handle slave devices (bonding)
sub getSlaves {
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
sub getVirtualDev {
    my ($name, $pcislot) = @_;

    my $virtualdev;

    if (-d "/sys/devices/virtual/net/") {
        $virtualdev = -d "/sys/devices/virtual/net/$name" ? 1 : 0;
    } else {
        if (can_run("brctl")) {
            # Let's guess
            my %bridge;
            foreach (`brctl show`) {
                next if /^bridge name/;
                $bridge{$1} = 1 if /^(\w+)\s/;
            }
            if ($pcislot) {
                $virtualdev = "no";
            } elsif ($bridge{$name}) {
                $virtualdev = "yes";
            }
        }
    }

    return $virtualdev;
}

sub isWifi {
    my ($name) = @_;

    my @wifistatus = `/sbin/iwconfig $name 2>/dev/null`;
    return @wifistatus > 2;
}

sub getUevent {
    my ($name) = @_;

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
            warn "Can't open $file: $ERRNO";
        }
    }

    return ($driver, $pcislot);
}

sub getNetworkInfo {
    my ($address, $mask, $gateway) = @_;

    # import Net::IP functional interface
    Net::IP->import(':PROC');

    my ($ipsubnet, $ipgateway);

    my $binip = ip_iptobin($address, 4);
    my $binmask = ip_iptobin($mask, 4);
    my $binsubnet = $binip & $binmask;

    $ipsubnet = ip_bintoip($binsubnet, 4);
    $ipgateway = $gateway->{$ipsubnet};

    # replace '0.0.0.0' (ie 'default gateway') by the
    # default gateway IP adress if it exists
    if ($ipgateway and
        $ipgateway eq '0.0.0.0' and 
        $gateway->{'0.0.0.0'}
    ) {
        $ipgateway = $gateway->{'0.0.0.0'}
    }

    return ($ipsubnet, $ipgateway);
}

1;
