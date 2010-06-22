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

    my $interfaces = parseIfconfig('/sbin/ifconfig -a', '-|', \%gateway);

    foreach my $interface (@$interfaces) {
        $inventory->addNetwork($interface);
    }
}

sub parseIfconfig {
    my ($file, $mode, $gateway) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $interfaces;

    my $interface = { STATUS => 'Down' };

    while (my $line = <$handle>) {
        if ( $line =~ /^$/ ) {
            # end of interface section
            # I write the entry

            if (!$interface->{DESCRIPTION}) {
                next;
            }

            if ($interface->{IPADDRESS} && $interface->{IPMASK}) {
                # import Net::IP functional interface
                Net::IP->import(':PROC');

                my $binip = ip_iptobin($interface->{IPADDRESS}, 4);
                my $binmask = ip_iptobin($interface->{IPMASK}, 4);
                my $binsubnet = $binip & $binmask;
                $interface->{IPSUBNET} = ip_bintoip($binsubnet, 4);
                $interface->{IPGATEWAY} = $gateway->{$interface->{IPSUBNET}};
                # replace '0.0.0.0' (ie 'default gateway') by the
                # default gateway IP adress if it exists
                if (
                    $interface->{IPGATEWAY} and
                    $interface->{IPGATEWAY} eq '0.0.0.0' and 
                    $gateway->{'0.0.0.0'}
                ) {
                    $interface->{IPGATEWAY} = $gateway->{'0.0.0.0'}
                }
            }

            my @wifistatus = `/sbin/iwconfig $interface->{DESCRIPTION} 2>>/dev/null`;
            if ( @wifistatus > 2 ) {
                $interface->{TYPE} = "Wifi";
            }

            my $file = "/sys/class/net/$interface->{DESCRIPTION}/device/uevent";
            if (-r $file) {
                if (open my $handle, '<', $file) {
                    while (<$handle>) {
                        $interface->{DRIVER} = $1 if /^DRIVER=(\S+)/;
                        $interface->{PCISLOT} = $1 if /^PCI_SLOT_NAME=(\S+)/;
                    }
                    close $handle;
                } else {
                    warn "Can't open $file: $ERRNO";
                }
            }

            # Handle channel bonding interfaces
            my @slaves = ();
            while (my $slave = glob("/sys/class/net/".$interface->{DESCRIPTION}."/slave_*")) {
                if ( $slave =~ /\/slave_(\w+)/ ) {
                    push( @slaves, $1 );
                }
            }
            $interface->{SLAVES} = join(',',@slaves);

            # Handle virtual devices (bridge)
            if (-d "/sys/devices/virtual/net/") {
                $interface->{VIRTUALDEV} = (-d "/sys/devices/virtual/net/".$interface->{DESCRIPTION})?"1":"0";
            } elsif (can_run("brctl")) {
                # Let's guess
                my %bridge;
                foreach (`brctl show`) {
                    next if /^bridge name/;
                    $bridge{$1} = 1 if /^(\w+)\s/;
                }
                if ($interface->{PCISLOT}) {
                    $interface->{VIRTUALDEV} = "no";
                } elsif ($bridge{$interface->{DESCRIPTION}}) {
                    $interface->{VIRTUALDEV} = "yes";
                }
            }

            $interface->{IPDHCP} = getIpDhcp($interface->{DESCRIPTION});

            push @$interfaces, $interface;

            $interface = { STATUS => 'Down' };

        } else { # In a section
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

1;
