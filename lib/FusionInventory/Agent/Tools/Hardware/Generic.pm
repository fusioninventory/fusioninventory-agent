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


    my $firstMethodIsASuccess;

    my $dot1dTpFdbAddress    = $snmp->walk($model->{oids}->{dot1dTpFdbAddress} || '.1.3.6.1.2.1.17.4.3.1.1');
    my $dot1dTpFdbPort       = $snmp->walk($model->{oids}->{dot1dTpFdbPort} || '.1.3.6.1.2.1.17.4.3.1.2');
    my $dot1dBasePortIfIndex = $snmp->walk($model->{oids}->{dot1dBasePortIfIndex} || '.1.3.6.1.2.1.17.1.4.1.2');
    # New OID, not yet in model files most of the time
    my $dot1qTpFdbPort       = $snmp->walk($model->{oids}->{dot1qTpFdbPort} || '.1.3.6.1.2.1.17.7.1.2.2.1.2');
    my $dot1qTpFdbStatus     = $snmp->walk($model->{oids}->{dot1qTpFdbStatus} || '.1.3.6.1.2.1.17.7.1.2.2.1.3');

    # Ok, we tried to find the remote devices using dot1dTpFdbAddress without success,
    # let's try by using dot1qTpFdbPort this time. This alternative solution is known
    # to work at last with Juniper ex2200 devices.
    #
    #
    # Frédéric Grosjean
    # Voila la méthode qui, a priori, fonctionne quel que soit le modèle.
    #
    # Recherche de la mac sur l'interface ge-0/0/8.0 sur mydevice
    # sur les interfaces sans 0 (ge-0/0/8), il n'y a rien,
    # si on peut les supprimer de glpi ça serait bien
    #
    #
    # snmpwalk -v 2c -c public mydevice 1.3.6.1.2.1.31.1.1.1.1 | grep ge-0/0/8.0
    # iso.3.6.1.2.1.31.1.1.1.1.519 = STRING: "ge-0/0/8.0"
    #
    # snmpwalk -v 2c -c public mydevice dot1dBasePortIfIndex | grep '= INTEGER: 519'
    # iso.3.6.1.2.1.17.1.4.1.2.521 = INTEGER: 519
    #
    # snmpwalk -v 2c -c public mydevice 1.3.6.1.2.1.17.7.1.2.2 | grep '= INTEGER: 521'
    # iso.3.6.1.2.1.17.7.1.2.2.1.2.27.204.82.175.74.75.152 = INTEGER: 521
    #
    #
    # 204.82.175.74.75.152 = cc:52:af:4a:4b:98
    #
    # vérification sur mydevice
    #
    # show ethernet-switching table | match ge-0/0/8
    # pmf-lan-foo      cc:52:af:4a:4b:98 Learn          0 ge-0/0/8.0
    foreach my $ifKey (sort keys %{$ports}) {
        next unless $ports->{$ifKey}{IFNAME};

        my $port_id;
        foreach my $t (keys %$dot1dBasePortIfIndex) {
            next unless $t;
            next unless $dot1dBasePortIfIndex->{$t};
            next unless $ifKey;
            next unless $dot1dBasePortIfIndex->{$t} eq $ifKey;

            $port_id = $t;
            last;
        }
        next unless $port_id;

        foreach my $t (keys %$dot1qTpFdbPort) {
            next unless $t;
            next unless $dot1qTpFdbPort->{$t};
            next unless $dot1qTpFdbPort->{$t} eq $port_id;

            my ($vlan_id, @macDecimal) = split(/\./, $t);
            my $mac = sprintf ("%02x:%02x:%02x:%02x:%02x:%02x", @macDecimal);
            push
                @{$ports->{$ifKey}{CONNECTIONS}{CONNECTION}{MAC}},
                $mac;

            $firstMethodIsASuccess = 1;

        }

    }

    return if $firstMethodIsASuccess;

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

sub setConnectedDevices {
    my (%params) = @_;

    my $model = $params{model};

    if      ($model->{oids}->{cdpCacheAddress}) {
        setConnectedDevicesUsingCDP(%params);
    } elsif ($model->{oids}->{lldpRemChassisId}) {
        setConnectedDevicesUsingLLDP(%params);
    }
}

sub setConnectedDevicesUsingCDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $ports  = $params{ports};
    my $logger = $params{logger};

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

        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check cdpCacheAddress mapping")
                if $logger;
            last;
        }

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

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $connection
        };
    }
}

sub setConnectedDevicesUsingLLDP {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $ports  = $params{ports};
    my $logger = $params{logger};

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

        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check lldpRemChassisId mapping")
                if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => {
                SYSMAC   => scalar alt2canonical($mac),
                IFDESCR  => $lldpRemPortDesc->{$suffix},
                SYSDESCR => $lldpRemSysDesc->{$suffix},
                SYSNAME  => $lldpRemSysName->{$suffix},
                IFNUMBER => $lldpRemPortId->{$suffix}
            }
        };
    }
}

sub setTrunkPorts {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $ports  = $params{ports};
    my $logger = $params{logger};

    my $results = $snmp->walk($model->{oids}->{vlanTrunkPortDynamicStatus});
    while (my ($suffix, $trunk) = each %{$results}) {
        my $port_id = getElement($suffix, -1);

        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check vlanTrunkPortDynamicStatus mapping")
                if $logger;
            last;
        }
        $ports->{$port_id}->{TRUNK} = $trunk ? 1 : 0;
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Hardware::Generic - Generic hardware-relatedfunctions

=head1 DESCRIPTION

This module provides some generic implementation of hardware-related functions.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddresses(%params)

set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setConnectedDevices

Set connected devices using CDP if available, LLDP otherwise.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setConnectedDevicesUsingCDP

Set connected devices using CDP

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setConnectedDevicesUsingLLDP

Set connected devices using LLDP

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setTrunkPorts

Set trunk flag on ports needing it.

=over

=item results raw values collected through SNMP

=item ports device ports list

=back
