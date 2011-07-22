package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Cisco;

use strict;
use warnings;

use FusionInventory::Agent::Task::SNMPQuery::Tools;

sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks, $vlan_id) = @_;

    while (my ($number, $ifphysaddress) = each %{$results->{VLAN}->{$vlan_id}->{dot1dTpFdbAddress}}) {
        next unless $ifphysaddress;

        my $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $short_number;
        my $ifKey_part =
            $results->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;

        my $ifKey =
            $walks->{dot1dBasePortIfIndex}->{OID} .  '.' . $ifKey_part;
        next unless defined $ifKey;

        my $ifIndex =
            $results->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{$ifKey};
        next unless defined $ifIndex;

        my $port = $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}];

        next if exists $port->{CONNECTIONS}->{CDP};
        next if $ifphysaddress eq $port->{MAC};

        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

sub setTrunkPorts {
    my ($results, $deviceports, $ports) = @_;

    while (my ($port_id, $trunk) = each %{$results->{vlanTrunkPortDynamicStatus}}) {
        $deviceports->[$ports->{lastSplitObject($port_id)}]->{TRUNK} = $trunk ? 1 : 0;
    }
}

sub setCDPPorts {
    my ($results, $datadevice, $walks, $ports) = @_;

    return unless ref $results->{cdpCacheAddress} eq 'HASH';

    while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
        my $ip = hex2stringAddress($ip_hex);
        next if $ip eq '0.0.0.0';

        my $short_number = $number;
        $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
        my @array = split(/\./, $short_number);

        my $connections =
            $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS};

        $connections->{CONNECTION}->{IP} = $ip;
        $connections->{CDP} = 1;
        if (defined($results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number})) {
            $connections->{CONNECTION}->{IFDESCR} = $results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number};
        }
    }
}

1;
