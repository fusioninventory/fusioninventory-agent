package FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run('lscfg') ||
        can_run('ifconfig');
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my @interfaces = _getInterfaces();
    foreach my $interface (@interfaces) {
        $inventory->addEntry({
            section => 'NETWORKS',
            entry   => $interface
        });
    }

    # set global parameters
    my @ip_addresses =
        grep { ! /^127/ }
        grep { $_ }
        map { $_->{IPADDRESS} }
        @interfaces;

    $inventory->setHardware({
        IPADDR => join('/', @ip_addresses)
    });
}

sub _getInterfaces {

    my %interfaces;

    foreach (`lscfg -v -l en*`) {
        next unless /^\s+ent(\d+)\s+\S+\s+(.+)/;
        my $name = "en".$1;
        $interfaces{$name}->{TYPE} = $2;
        $interfaces{$name}->{DESCRIPTION} = $name;
        if (/Network Address\.+(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/) {
            $interfaces{$name}->{MACADDR} = "$1:$2:$3:$4:$5:$6"
        }
    } 

    foreach (split / /,`ifconfig -l`) {
        # network interface naming is enX
        next unless /^(en\d+)/;
        my $name = $1;
        foreach (`lsattr -E -l $name`) {
            $interfaces{$name}->{IPADDRESS} = $1 if /^netaddr \s*([\d*\.?]*)/i;
            $interfaces{$name}->{IPMASK} = $1 if /^netmask\s*([\d*\.?]*)/i;
            $interfaces{$name}->{STATUS} = $1 if /^state\s*(\w*)/i; 
        } 
    }

    foreach my $interface (values %interfaces) { 
        $interface->{STATUS} = "Down" unless $interface->{IPADDRESS};
        $interface->{IPDHCP} = "No";

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK},
        );
    }

    return values %interfaces;
}

1;
