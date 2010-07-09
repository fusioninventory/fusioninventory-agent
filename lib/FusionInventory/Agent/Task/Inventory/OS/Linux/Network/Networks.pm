package FusionInventory::Agent::Task::Inventory::OS::Linux::Network::Networks;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return unless can_run("ifconfig") && can_run("route") && can_load("Net::IP qw(:PROC)");

    1;
}


sub _ipdhcp {
    my $if = shift;

    my $path;
    my $dhcp;
    my $ipdhcp;
    my $leasepath;

    foreach (
        "/var/lib/dhcp3/dhclient.%s.leases",
        "/var/lib/dhcp3/dhclient.%s.leases",
        "/var/lib/dhcp/dhclient.leases", ) {

        $leasepath = sprintf($_,$if);
        last if (-e $leasepath);
    }
    return unless -e $leasepath;

    if (open my $handle, '<', $leasepath) {
        my $lease;
        while (<$handle>) {
            $lease = 1 if(/lease\s*{/i);
            $lease = 0 if(/^\s*}\s*$/);
            #Interface name
            if ($lease) { #inside a lease section
                if(/interface\s+"(.+?)"\s*/){
                    $dhcp = ($1 =~ /^$if$/);
                }
                #Server IP
                if(/option\s+dhcp-server-identifier\s+(\d{1,3}(?:\.\d{1,3}){3})\s*;/ and $dhcp){
                    $ipdhcp = $1;
                }
            }
        }
        close $handle;
    } else {
        warn "Can't open $leasepath: $ERRNO";
    }
    return $ipdhcp;
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

    if (defined ($gateway{'0.0.0.0'})) {
        $inventory->setHardware({
                DEFAULTGATEWAY => $gateway{'0.0.0.0'}
            });
    }

    my %ifData = (
        STATUS => 'Down',
    );

    foreach my $line (`ifconfig -a`) {
        if ( $line =~ /^$/ ) {
            # end of interface section
            # I write the entry

            if ( !defined($ifData{DESCRIPTION}) ) {
                next;
            }

            if ( defined($ifData{IPADDRESS}) && defined($ifData{IPMASK}) ) {
                my $binip = ip_iptobin ($ifData{IPADDRESS} ,4);
                my $binmask = ip_iptobin ($ifData{IPMASK} ,4);
                my $binsubnet = $binip & $binmask;
                $ifData{IPSUBNET} = ip_bintoip($binsubnet,4);
                $ifData{IPGATEWAY} = $gateway{$ifData{IPSUBNET}};
                # replace '0.0.0.0' (ie 'default gateway') by the default gateway IP adress if it exists
                if (defined($ifData{IPGATEWAY}) and $ifData{IPGATEWAY} eq '0.0.0.0' and defined($gateway{'0.0.0.0'})) {
                    $ifData{IPGATEWAY} = $gateway{'0.0.0.0'}
                }
            }

            my @wifistatus = `iwconfig $ifData{DESCRIPTION} 2>>/dev/null`;
            if ( @wifistatus > 2 ) {
                $ifData{TYPE} = "Wifi";
            }

            if (open my $handle, '<', "/sys/class/net/$ifData{DESCRIPTION}/device/uevent") {
                while (<$handle>) {
                    $ifData{DRIVER} = $1 if /^DRIVER=(\S+)/;
                    $ifData{PCISLOT} = $1 if /^PCI_SLOT_NAME=(\S+)/;
                }
                close $handle;
            } else {
                $logger->debug("Can't open ".
                    "/sys/class/net/".
                    $ifData{DESCRIPTION}.
                    "/device/uevent: ".
                    $ERRNO);
            }

            # Handle channel bonding interfaces
            my @slaves = ();
            while (my $slave = glob("/sys/class/net/".$ifData{DESCRIPTION}."/slave_*")) {
                if ( $slave =~ /\/slave_(\w+)/ ) {
                    push( @slaves, $1 );
                }
            }
            $ifData{SLAVES} = join(',',@slaves);

            # Handle virtual devices (bridge)
            if (-d "/sys/devices/virtual/net/") {
                $ifData{VIRTUALDEV} = (-d "/sys/devices/virtual/net/".$ifData{DESCRIPTION})?"1":"0";
            } elsif (can_run("brctl")) {
                # Let's guess
                my %bridge;
                foreach (`brctl show`) {
                    next if /^bridge name/;
                    $bridge{$1} = 1 if /^(\w+)\s/;
                }
                if ($ifData{PCISLOT}) {
                    $ifData{VIRTUALDEV} = "no";
                } elsif ($bridge{$ifData{DESCRIPTION}}) {
                    $ifData{VIRTUALDEV} = "yes";
                }
            }

            $ifData{IPDHCP} = _ipdhcp($ifData{DESCRIPTION});

            $inventory->addNetwork(\%ifData);

            %ifData = (
                STATUS => 'Down',
            );

        } else { # In a section

            $ifData{DESCRIPTION} = $1 if $line =~ /^(\S+)/; # Interface name
            $ifData{IPADDRESS} = $1 if $line =~ /inet addr:(\S+)/i;
            $ifData{IPMASK} = $1 if $line =~ /\S*mask:(\S+)/i;
            $ifData{MACADDR} = $1 if $line =~ /hwadd?r\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/i;
            $ifData{STATUS} = 'Up' if $line =~ /^\s+UP\s/;
            $ifData{TYPE} = $1 if $line =~ /link encap:(\S+)/i;
        }

    }
}

1;
