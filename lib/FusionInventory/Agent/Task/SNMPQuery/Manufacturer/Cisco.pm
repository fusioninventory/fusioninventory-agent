package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Cisco;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer';

use FusionInventory::Agent::Task::SNMPQuery::Tools;
use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddress {
    my ($class, $results, $ports, $walks, $vlan_id) = @_;

    while (my ($oid, $mac) = each %{$results->{VLAN}->{$vlan_id}->{dot1dTpFdbAddress}}) {
        next unless $mac;

        my $suffix = $oid;
        $suffix =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $suffix;
        my $ifKey_part =
            $results->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;

        my $ifKey =
            $walks->{dot1dBasePortIfIndex}->{OID} .  '.' . $ifKey_part;
        next unless defined $ifKey;

        my $ifIndex =
            $results->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{$ifKey};
        next unless defined $ifIndex;

        my $port = $ports->[$ifIndex];

        # this device has already been processed through CDP/LLDP
        next if $port->{CONNECTIONS}->{CDP};
        # this is port own mac address
        next if $port->{MAC} eq $mac;

        # create a new connection with this mac address
        my $connections = $port->{CONNECTIONS}->{CONNECTION};
        push @$connections, { MAC => $mac };
    }
}

sub setTrunkPorts {
    my ($class, $results, $ports) = @_;

    while (my ($port_id, $trunk) = each %{$results->{vlanTrunkPortDynamicStatus}}) {
        $ports->[getLastNumber($port_id)]->{TRUNK} = $trunk ? 1 : 0;
    }
}

sub setConnectedDevices {
    my ($class, $results, $ports, $walks) = @_;

    return unless ref $results->{cdpCacheAddress} eq 'HASH';

    while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
        my $ip = hex2canonical($ip_hex);
        next if $ip eq '0.0.0.0';

        my $short_number = $number;
        $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
        my @array = split(/\./, $short_number);

        my $connections =
            $ports->[$array[1]]->{CONNECTIONS};

        $connections->{CDP} = 1;
        $connections->{CONNECTION}->{IP} = $ip;
        $connections->{CONNECTION}->{IFDESCR} = $results->{cdpCacheDevicePort}->{
            $walks->{cdpCacheDevicePort}->{OID} . $short_number
        };
        $connections->{CONNECTION}->{SYSDESCR} = $results->{cdpCacheVersion}->{
            $walks->{cdpCacheVersion}->{OID} . $short_number
        };
        $connections->{CONNECTION}->{SYSNAME} = $results->{cdpCacheDeviceId}->{
            $walks->{cdpCacheDeviceId}->{OID} . $short_number
        };
        $connections->{CONNECTION}->{MODEL} = $results->{cdpCachePlatform}->{
            $walks->{cdpCachePlatform}->{OID} . $short_number
        };
    }
}

1;
