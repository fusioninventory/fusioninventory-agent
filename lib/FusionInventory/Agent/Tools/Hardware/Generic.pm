package FusionInventory::Agent::Tools::Hardware::Generic;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $ports  = $params{ports};
    my $logger = $params{logger};

    my $dot1dTpFdbAddress    = $snmp->walk($model->{oids}->{dot1dTpFdbAddress});
    my $dot1dTpFdbPort       = $snmp->walk($model->{oids}->{dot1dTpFdbPort});
    my $dot1dBasePortIfIndex = $snmp->walk($model->{oids}->{dot1dBasePortIfIndex});

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

        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check dot1d* mappings")
                if $logger;
            last;
        }

        my $port = $ports->{$port_id};

        # this device has already been processed through CDP/LLDP
        next if $port->{CONNECTIONS}->{CDP};

        # this is port own mac address
        next if $port->{MAC} && $port->{MAC} eq $mac;

        # create a new connection with this mac address
        push
            @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}},
            $mac;
    }
}

sub setConnectedDevicesInfo {
    my (%params) = @_;

    my $model = $params{model};

    if      ($model->{oids}->{cdpCacheAddress}) {
        _setConnectedDevicesInfoCDP(%params);
    } elsif ($model->{oids}->{lldpRemChassisId}) {
        _setConnectedDevicesInfoLLDP(%params);
    }
}

sub _setConnectedDevicesInfoCDP {
    my (%params) = @_;

    my $cdp_info = _getConnectedDevicesInfoCDP(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $cdp_info;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$cdp_info) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check cdpCacheAddress mapping")
                if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $cdp_info->{$port_id}
        };
    }
}

sub _getConnectedDevicesInfoCDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $cdpCacheAddress    = $snmp->walk($model->{oids}->{cdpCacheAddress});
    my $cdpCacheDeviceId   = $snmp->walk($model->{oids}->{cdpCacheDeviceId});
    my $cdpCacheDevicePort = $snmp->walk($model->{oids}->{cdpCacheDevicePort});
    my $cdpCacheVersion    = $snmp->walk($model->{oids}->{cdpCacheVersion});
    my $cdpCachePlatform   = $snmp->walk($model->{oids}->{cdpCachePlatform});

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

sub _setConnectedDevicesInfoLLDP {
    my (%params) = @_;

    my $lldp_info = _getConnectedDevicesInfoLLDP(
        snmp  => $params{snmp},
        model => $params{model}
    );
    return unless $lldp_info;

    my $ports  = $params{ports};
    my $logger = $params{logger};

    foreach my $port_id (keys %$lldp_info) {
        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check lldpRemChassisId mapping")
                if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $lldp_info->{$port_id}
        };
    }
}

sub _getConnectedDevicesInfoLLDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};

    my $results;
    my $lldpRemChassisId = $snmp->walk($model->{oids}->{lldpRemChassisId});
    my $lldpRemPortId    = $snmp->walk($model->{oids}->{lldpRemPortId});
    my $lldpRemPortDesc  = $snmp->walk($model->{oids}->{lldpRemPortDesc});
    my $lldpRemSysDesc   = $snmp->walk($model->{oids}->{lldpRemSysDesc});
    my $lldpRemSysName   = $snmp->walk($model->{oids}->{lldpRemSysName});

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
    my $vlanStatus = $snmp->walk($model->{oids}->{vlanTrunkPortDynamicStatus});
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
