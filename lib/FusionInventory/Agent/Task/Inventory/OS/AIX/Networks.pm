package FusionInventory::Agent::Task::Inventory::OS::AIX::Networks;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Regexp;

sub isInventoryEnabled {
    return
        can_run('lscfg') ||
        can_run('ifconfig');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my @interfaces = _getInterfaces();
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
        IPADDR => join('/', @ip_addresses)
    });
}

sub _getInterfaces {

    my @interfaces = _parseLscfg(
        command => 'lscfg -v -l en*'
    );

    foreach my $interface (@interfaces) {
        my $handle = getFileHandle(
            command => "lsattr -E -l $interface->{DESCRIPTION}"
        );
        next unless $handle;

        while (my $line = <$handle>) {
            $interface->{IPADDRESS} = $1
                if $line =~ /^netaddr \s+ ($ip_address_pattern)/x;
            $interface->{IPMASK} = $1
                if $line =~ /^netmask \s+ ($ip_address_pattern)/x;
            $interface->{STATUS} = $1
                if $line =~ /^state \s+ (\w+)/x; 
        }
        close $handle;
    }

    foreach my $interface (@interfaces) { 
        $interface->{STATUS} = "Down" unless $interface->{IPADDRESS};
        $interface->{IPDHCP} = "No";

        $interface->{IPSUBNET} = getSubnetAddress(
            $interface->{IPADDRESS},
            $interface->{IPMASK},
        );
    }

    return @interfaces;
}

sub _parseLscfg {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @interfaces;
    my $interface;
    while (my $line = <$handle>) {
        if ($line =~ /^\s+ ent(\d+) \s+ \S+ \s+ (.+)/x) {
            push @interfaces, $interface if $interface;
            undef $interface;
            $interface->{TYPE} = $2;
            $interface->{DESCRIPTION} = "en$1";
        }
        if ($line =~ /Network \s Address \.+ (\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/x) {
            $interface->{MACADDR} = "$1:$2:$3:$4:$5:$6";
        }
    }
    close $handle;
    push @interfaces, $interface if $interface;

    return @interfaces;
}

1;
