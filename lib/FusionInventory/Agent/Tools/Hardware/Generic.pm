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

    my $dot1dTpFdbAddress    = $snmp->walk($model->{WALK}->{dot1dTpFdbAddress}->{OID});
    my $dot1dTpFdbPort       = $snmp->walk($model->{WALK}->{dot1dTpFdbPort}->{OID});
    my $dot1dBasePortIfIndex = $snmp->walk($model->{WALK}->{dot1dBasePortIfIndex}->{OID});

    foreach my $oid (sort keys %{$dot1dTpFdbAddress}) {
        my $mac = $dot1dTpFdbAddress->{$oid};
        $mac = alt2canonical($mac);
        next unless $mac;

        # get port key
        my $portKey_part = $oid;
        $portKey_part =~ s/$model->{WALK}->{dot1dTpFdbAddress}->{OID}\.//;
        next unless $portKey_part;
        my $portKey = $model->{WALK}->{dot1dTpFdbPort}->{OID} . '.' . $portKey_part;

        # get interface key from port key
        my $ifKey_part = $dot1dTpFdbPort->{$portKey};
        next unless defined $ifKey_part;
        my $ifKey = $model->{WALK}->{dot1dBasePortIfIndex}->{OID} . '.' . $ifKey_part;

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

    if      ($model->{WALK}->{cdpCacheAddress}) {
        setConnectedDevicesUsingCDP(%params);
    } elsif ($model->{WALK}->{lldpRemChassisId}) {
        setConnectedDevicesUsingLLDP(%params);
    }
}

sub setConnectedDevicesUsingCDP {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $cdpCacheAddress    = $snmp->walk($model->{WALK}->{cdpCacheAddress}->{OID});
    my $cdpCacheDeviceId   = $snmp->walk($model->{WALK}->{cdpCacheDeviceId}->{OID});
    my $cdpCacheDevicePort = $snmp->walk($model->{WALK}->{cdpCacheDevicePort}->{OID});
    my $cdpCacheVersion    = $snmp->walk($model->{WALK}->{cdpCacheVersion}->{OID});
    my $cdpCachePlatform   = $snmp->walk($model->{WALK}->{cdpCachePlatform}->{OID});

    while (my ($oid, $ip) = each %{$cdpCacheAddress}) {
        $ip = hex2canonical($ip);
        next if $ip eq '0.0.0.0';

        my $port_number =
            getElement($oid, -2) . "." .
            getElement($oid, -1);

        my $mac;
        my $sysname = $cdpCacheDeviceId->{$model->{WALK}->{cdpCacheDeviceId}->{OID} . "." . $port_number};
        if ($sysname =~ /^SIP([A-F0-9a-f]*)$/) {
            $mac = alt2canonical("0x".$1);
        }

        my $connection = {
            IP      => $ip,
            MAC     => $mac,
            IFDESCR => $cdpCacheDevicePort->{
                $model->{WALK}->{cdpCacheDevicePort}->{OID} . "." . $port_number
            },
            SYSDESCR => $cdpCacheVersion->{
                $model->{WALK}->{cdpCacheVersion}->{OID} . "." . $port_number
            },
            SYSNAME  => $sysname,
            MODEL => $cdpCachePlatform->{
                $model->{WALK}->{cdpCachePlatform}->{OID} . "." . $port_number
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

    my $lldpRemChassisId = $snmp->walk($model->{WALK}->{lldpRemChassisId}->{OID});
    my $lldpRemPortDesc  = $snmp->walk($model->{WALK}->{lldpRemPortDesc}->{OID});
    my $lldpRemSysDesc   = $snmp->walk($model->{WALK}->{lldpRemSysDesc}->{OID});
    my $lldpRemSysName   = $snmp->walk($model->{WALK}->{lldpRemSysName}->{OID});
    my $lldpRemPortId    = $snmp->walk($model->{WALK}->{lldpRemPortId}->{OID});

    while (my ($oid, $mac) = each %{$lldpRemChassisId}) {

        my $port_number =
            getElement($oid, -3) . "." .
            getElement($oid, -2) . "." .
            getElement($oid, -1);

        $ports->{getElement($oid, -2)}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => {
                SYSMAC => alt2canonical($mac),
                IFDESCR => $lldpRemPortDesc->{
                    $model->{WALK}->{lldpRemPortDesc}->{OID} . "." . $port_number
                },
                SYSDESCR => $lldpRemSysDesc->{
                    $model->{WALK}->{lldpRemSysDesc}->{OID} . "." . $port_number
                },
                SYSNAME  => alt2canonical($lldpRemSysName->{
                    $model->{WALK}->{lldpRemSysName}->{OID} . "." . $port_number
                }),
                IFNUMBER => $lldpRemPortId->{
                    $model->{WALK}->{lldpRemPortId}->{OID} . "." . $port_number
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

    my $results = $snmp->walk($model->{WALK}->{vlanTrunkPortDynamicStatus}->{OID});
    while (my ($oid, $trunk) = each %{$results}) {
        $ports->{getLastElement($oid)}->{TRUNK} = $trunk ? 1 : 0;
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
