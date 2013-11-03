package FusionInventory::Agent::Tools::Hardware::Generic;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $mac_addresses = _getConnectedDevicesMacAddresses(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $mac_addresses;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$mac_addresses) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check dot1d* mappings")
                if $logger;
            last;
        }

        my $port = $ports->{$port_id};

        # connected device has already been identified through CDP/LLDP
        next if $port->{CONNECTIONS}->{CDP};

        # get at list of already associated addresses, if any
        # as well as the port own mac address, if known
        my @known;
        push @known, $port->{MAC} if $port->{MAC};
        push @known, @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}}
            if $port->{CONNECTIONS}->{CONNECTION}->{MAC};

        # filter out those addresses from the additional ones
        my %known = map { $_ => 1 } @known;
        my @adresses = grep { !$known{$_} } @{$mac_addresses->{$port_id}};
        next unless @adresses;

        # add remaining ones
        push @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}}, @adresses;
    }
}

sub _getConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $dot1dTpFdbAddress    = $snmp->walk(
        $model->{oids}->{dot1dTpFdbAddress}    || '.1.3.6.1.2.1.17.4.3.1.1'
    );
    my $dot1dTpFdbPort       = $snmp->walk(
        $model->{oids}->{dot1dTpFdbPort}       || '.1.3.6.1.2.1.17.4.3.1.2'
    );
    my $dot1dBasePortIfIndex = $snmp->walk(
        $model->{oids}->{dot1dBasePortIfIndex} || '.1.3.6.1.2.1.17.1.4.1.2'
    );

    foreach my $suffix (sort keys %{$dot1dTpFdbAddress}) {
        my $mac = $dot1dTpFdbAddress->{$suffix};
        $mac = alt2canonical($mac);
        next unless $mac;

        # get port key
        my $portKey = $suffix;
        next unless $portKey;

        # get interface key from port key
        my $ifKey = $dot1dTpFdbPort->{$portKey};
        next unless defined $ifKey;

        # get interface index
        my $port_id = $dot1dBasePortIfIndex->{$ifKey};
        next unless defined $port_id;

        push @{$results->{$port_id}}, $mac;
    }

    return $results;
}

sub setConnectedDevicesInfo {
    my (%params) = @_;

    my $info =
        _getConnectedDevicesInfoCDP(%params) ||
        _getConnectedDevicesInfoLLDP(%params);
    return unless $info;

    my $logger = $params{logger};
    my $ports  = $params{ports};

    foreach my $port_id (keys %$info) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error(
                "non-existing port $port_id, check CDP/LLDP mappings"
            ) if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $info->{$port_id}
        };
    }
}

sub _getConnectedDevicesInfoCDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $cdpCacheAddress    = $snmp->walk(
        $model->{oids}->{cdpCacheAddress}    || '.1.3.6.1.4.1.9.9.23.1.2.1.1.4'
    );
    my $cdpCacheVersion    = $snmp->walk(
        $model->{oids}->{cdpCacheVersion}    || '.1.3.6.1.4.1.9.9.23.1.2.1.1.5'
    );
    my $cdpCacheDeviceId   = $snmp->walk(
        $model->{oids}->{cdpCacheDeviceId}   || '.1.3.6.1.4.1.9.9.23.1.2.1.1.6'
    );
    my $cdpCacheDevicePort = $snmp->walk(
        $model->{oids}->{cdpCacheDevicePort} || '.1.3.6.1.4.1.9.9.23.1.2.1.1.7'
    );
    my $cdpCachePlatform   = $snmp->walk(
        $model->{oids}->{cdpCachePlatform}   || '.1.3.6.1.4.1.9.9.23.1.2.1.1.8'
    );

    # each cdp variable matches the following scheme:
    # $prefix.x.y = $value
    # whereas x is the port number

    while (my ($suffix, $ip) = each %{$cdpCacheAddress}) {
        my $port_id = getElement($suffix, -2);
        $ip = hex2canonical($ip);
        next if $ip eq '0.0.0.0';

        my $connection = {
            IP       => $ip,
            IFDESCR  => $cdpCacheDevicePort->{$suffix},
            SYSDESCR => $cdpCacheVersion->{$suffix},
            SYSNAME  => $cdpCacheDeviceId->{$suffix},
            MODEL    => $cdpCachePlatform->{$suffix}
        };

        if ($connection->{SYSNAME} =~ /^SIP([A-F0-9a-f]*)$/) {
            $connection->{MAC} = alt2canonical("0x".$1);
        }

        next if !$connection->{SYSDESCR} || !$connection->{MODEL};

        $results->{$port_id} = $connection;
    }

    return $results;
}

sub _getConnectedDevicesInfoLLDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $lldpRemChassisId = $snmp->walk(
        $model->{oids}->{lldpRemChassisId} || '.1.0.8802.1.1.2.1.4.1.1.5'
    );
    my $lldpRemPortId    = $snmp->walk(
        $model->{oids}->{lldpRemPortId}    || '.1.0.8802.1.1.2.1.4.1.1.7'
    );
    my $lldpRemPortDesc  = $snmp->walk(
        $model->{oids}->{lldpRemPortDesc}  || '.1.0.8802.1.1.2.1.4.1.1.8'
    );
    my $lldpRemSysName   = $snmp->walk(
        $model->{oids}->{lldpRemSysName}   || '.1.0.8802.1.1.2.1.4.1.1.9'
    );
    my $lldpRemSysDesc   = $snmp->walk(
        $model->{oids}->{lldpRemSysDesc}   || '.1.0.8802.1.1.2.1.4.1.1.10'
    );

    # each lldp variable matches the following scheme:
    # $prefix.x.y.z = $value
    # whereas y is the port number

    while (my ($suffix, $mac) = each %{$lldpRemChassisId}) {
        my $port_id = getElement($suffix, -2);
        $results->{$port_id} = {
            SYSMAC   => scalar alt2canonical($mac),
            IFDESCR  => $lldpRemPortDesc->{$suffix},
            SYSDESCR => $lldpRemSysDesc->{$suffix},
            SYSNAME  => $lldpRemSysName->{$suffix},
            IFNUMBER => $lldpRemPortId->{$suffix}
        };
    }

    return $results;
}

sub setTrunkPorts {
    my (%params) = @_;

    my $trunk_ports = _getTrunkPorts(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $trunk_ports;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$trunk_ports) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check vlanTrunkPortDynamicStatus mapping")
                if $logger;
            last;
        }
        $ports->{$port_id}->{TRUNK} = $trunk_ports->{$port_id};
    }
}

sub _getTrunkPorts {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $vlanStatus = $snmp->walk(
        $model->{oids}->{vlanTrunkPortDynamicStatus} ||
        '.1.3.6.1.4.1.9.9.46.1.6.1.1.14'
    );
    while (my ($suffix, $trunk) = each %{$vlanStatus}) {
        my $port_id = getElement($suffix, -1);
        $results->{$port_id} = $trunk ? 1 : 0;
    }

    return $results;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Hardware::Generic - Generic hardware-relatedfunctions

=head1 DESCRIPTION

This module provides some generic implementation of hardware-related functions.

=head1 FUNCTIONS

=head2 setConnectedDevicesInfo

Set connected devices information, using CDP if available, LLDP otherwise.

=over

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=item * logger: logger object

=back

=head2 setConnectedDevicesMacAddresses(%params)

set connected devices mac addresses, when previous method failed. 

=over

=item * snmp: FusionInventory::Agent::SNMP object

=item * model: SNMP model

=item * ports: device ports list

=item * logger: logger object

=back

=head2 setTrunkPorts

Set trunk flag on ports needing it.

=over

=item results raw values collected through SNMP

=item ports device ports list

=back
