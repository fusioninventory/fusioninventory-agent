package FusionInventory::Agent::Tools::Hardware::Generic;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $dot1dTpFdbAddress    = $snmp->walk($model->{oids}->{dot1dTpFdbAddress});
    my $dot1dTpFdbPort       = $snmp->walk($model->{oids}->{dot1dTpFdbPort});
    my $dot1dBasePortIfIndex = $snmp->walk($model->{oids}->{dot1dBasePortIfIndex});

    foreach my $oid (sort keys %{$dot1dTpFdbAddress}) {
        my $mac = $dot1dTpFdbAddress->{$oid};
        $mac = alt2canonical($mac);
        next unless $mac;

        # get port key
        my $portKey_part = $oid;
        $portKey_part =~ s/$model->{oids}->{dot1dTpFdbAddress}\.//;
        next unless $portKey_part;
        my $portKey = $model->{oids}->{dot1dTpFdbPort} . '.' . $portKey_part;

        # get interface key from port key
        my $ifKey_part = $dot1dTpFdbPort->{$portKey};
        next unless defined $ifKey_part;
        my $ifKey = $model->{oids}->{dot1dBasePortIfIndex} . '.' . $ifKey_part;

        # get interface index
        my $ifIndex = $dot1dBasePortIfIndex->{$ifKey};
        next unless defined $ifIndex;

        my $port = $ports->{$ifIndex};

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

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $cdpCacheAddress    = $snmp->walk($model->{oids}->{cdpCacheAddress});
    my $cdpCacheDeviceId   = $snmp->walk($model->{oids}->{cdpCacheDeviceId});
    my $cdpCacheDevicePort = $snmp->walk($model->{oids}->{cdpCacheDevicePort});
    my $cdpCacheVersion    = $snmp->walk($model->{oids}->{cdpCacheVersion});
    my $cdpCachePlatform   = $snmp->walk($model->{oids}->{cdpCachePlatform});

    while (my ($oid, $ip) = each %{$cdpCacheAddress}) {
        $ip = hex2canonical($ip);
        next if $ip eq '0.0.0.0';

        my $port_number =
            getElement($oid, -2) . "." .
            getElement($oid, -1);

        my $mac;
        my $sysname = $cdpCacheDeviceId->{$model->{oids}->{cdpCacheDeviceId} . "." . $port_number};
        if ($sysname =~ /^SIP([A-F0-9a-f]*)$/) {
            $mac = alt2canonical("0x".$1);
        }

        my $connection = {
            IP      => $ip,
            MAC     => $mac,
            IFDESCR => $cdpCacheDevicePort->{
                $model->{oids}->{cdpCacheDevicePort} . "." . $port_number
            },
            SYSDESCR => $cdpCacheVersion->{
                $model->{oids}->{cdpCacheVersion} . "." . $port_number
            },
            SYSNAME  => $sysname,
            MODEL => $cdpCachePlatform->{
                $model->{oids}->{cdpCachePlatform} . "." . $port_number
            }
        };

        next if !$connection->{SYSDESCR} || !$connection->{MODEL};

        $ports->{getElement($oid, -2)}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => $connection
        };
    }
}

sub setConnectedDevicesUsingLLDP {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $lldpRemChassisId = $snmp->walk($model->{oids}->{lldpRemChassisId});
    my $lldpRemPortId    = $snmp->walk($model->{oids}->{lldpRemPortId});
    my $lldpRemPortDesc  = $snmp->walk($model->{oids}->{lldpRemPortDesc});
    my $lldpRemSysDesc   = $snmp->walk($model->{oids}->{lldpRemSysDesc});
    my $lldpRemSysName   = $snmp->walk($model->{oids}->{lldpRemSysName});

    while (my ($oid, $mac) = each %{$lldpRemChassisId}) {

        my $port_number =
            getElement($oid, -3) . "." .
            getElement($oid, -2) . "." .
            getElement($oid, -1);

        $ports->{getElement($oid, -2)}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => {
                SYSMAC => scalar alt2canonical($mac),
                IFDESCR => $lldpRemPortDesc->{
                    $model->{oids}->{lldpRemPortDesc} . "." . $port_number
                },
                SYSDESCR => $lldpRemSysDesc->{
                    $model->{oids}->{lldpRemSysDesc} . "." . $port_number
                },
                SYSNAME  => scalar alt2canonical($lldpRemSysName->{
                    $model->{oids}->{lldpRemSysName} . "." . $port_number
                }),
                IFNUMBER => $lldpRemPortId->{
                    $model->{oids}->{lldpRemPortId} . "." . $port_number
                }
            }
        };
    }
}

sub setTrunkPorts {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $results = $snmp->walk($model->{oids}->{vlanTrunkPortDynamicStatus});
    while (my ($oid, $trunk) = each %{$results}) {
        $ports->{getElement($oid, -1)}->{TRUNK} = $trunk ? 1 : 0;
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
