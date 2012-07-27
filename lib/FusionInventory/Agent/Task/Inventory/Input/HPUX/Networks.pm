package FusionInventory::Agent::Task::Inventory::Input::HPUX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Network;

#TODO Get pcislot virtualdev

sub isEnabled {
    return canRun('lanscan');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # set list of network interfaces
    my $routes = getRoutingTable(command => 'netstat -nr', logger => $logger);
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

    my @ifLanScan = _parseLanscan(
        command => 'lanscan -iap',
        logger  => $params{logger}
    );

    my %ifStatNrv = _parseNetstatNrv();

    my @interfaces;
    foreach my $ifLanScan (@ifLanScan) {

        my $lanadminInfo = _getLanadminInfo(
            command => "lanadmin -g ".$ifLanScan->{lan_id}, logger => $params{logger}
        );
        $ifLanScan->{TYPE}        = $lanadminInfo->{'Type (value)'};
        $ifLanScan->{SPEED}       = $lanadminInfo->{Speed} > 1000000 ?
                                        $lanadminInfo->{Speed} / 1000000 :
                                        $lanadminInfo->{Speed};

        # Interface found in "netstat -nrv", let's use it
        if ($ifStatNrv{$ifLanScan->{DESCRIPTION}}) {
            foreach my $ifStatNrv (@{$ifStatNrv{$ifLanScan->{DESCRIPTION}}}) {
                foreach (keys %$ifLanScan) {
                $ifStatNrv->{$_} = $ifLanScan->{$_} if $ifLanScan->{$_};
                }
                push @interfaces, $ifStatNrv;
            }
        # O
        } else {
            my $ifconfigInfo = _getIfconfigInfo(
                command => "ifconfig ".$ifLanScan->{DESCRIPTION}, logger => $params{logger}
            );
            $ifLanScan->{STATUS}    = $ifconfigInfo->{status};
            $ifLanScan->{IPADDRESS} = $ifconfigInfo->{address};
            $ifLanScan->{IPMASK}    = $ifconfigInfo->{netmask};
            push @interfaces, $ifLanScan;
        }
    }

    foreach my $interface (@interfaces) {
        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK}
        );

        # Some cleanups
        if ($interface->{IPADDRESS} && ($interface->{IPADDRESS} eq '0.0.0.0')) {
            $interface->{IPADDRESS} = "";
            $interface->{IPSUBNET} = "";
            $interface->{IPMASK} = "";
        }
    }

    return @interfaces;
}

sub _parseLanscan {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @interfaces;
    while (my $line = <$handle>) {
        next unless $line =~ /^0x($alt_mac_address_pattern)\s(\S+)\s(\S+)\s+(\S+)/;
        my $interface = {
            MACADDR => alt2canonical($1),
            STATUS => 'Down',
            DESCRIPTION => $2,
            lan_id  => $4,
        };

        push @interfaces, $interface;
    }
    close $handle;

    return @interfaces;
}

sub _getLanadminInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        next unless $line =~ /^(\S.+\S) \s+ = \s (.+)$/x;
        $info->{$1} = $2;
    }
    close $handle;

    return $info;
}

sub _getIfconfigInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        if ($line =~ /<UP/) {
            $info->{status} = 'Up';
        }
        if ($line =~ /inet ($ip_address_pattern)/) {
            $info->{address} = $1;
        }
        if ($line =~ /netmask ($hex_ip_address_pattern)/) {
            $info->{netmask} = hex2canonical($1);
        }
    }
    close $handle;

    return $info;
}

# will be need to get the bonding configuration
sub _getNwmgrInfo {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        if ($line =~ /^(\w+)\s+(\w+)\s+0x(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})\s+(\w+)\s+(\w*)/) {
            my $netif = $1;

            $info->{$netif} = {
                status => $2,
                mac => join(':', ($3, $4, $5, $6, $7, $8)),
                driver => $9,
                media => $10,
                related_if => $11

            }

        }
    }
    close $handle;

    return $info;
}

sub _parseNetstatNrv {
    my (%params) = (
        command => 'netstat -nrv',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my %interfaces;
    while (my $line = <$handle>) {
        next unless $line =~ /^
            (
                $ip_address_pattern
            )
            \/
            (
                $ip_address_pattern
            )
            \s+
            (
                $ip_address_pattern # Gateway
            )
            \s+
            \w*H\w*   # Host only
            .*\s
            (
                \w+ # Interface name
            )
            (|:\d+) # ignore interface alias, e.g: lan0:1
            \s+
            (
                \d+ # MTU
            )
            $
            /x;

        my $ipgateway = $3 if $3 ne $1;

        push @{$interfaces{$4}}, {
            IPADDRESS => $1,
            IPMASK => $2,
            IPGATEWAY => $ipgateway,
            DESCRIPTION => $4,
            MTU => $6
        }
    }
    close $handle;

    return %interfaces;
}


1;
