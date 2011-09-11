package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Procurve;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddress {
    my ($results, $ports, $walks) = @_;

    while (my ($oid, $mac) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $mac;

        my $suffix = $oid;
        $suffix =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $suffix;
        my $ifKey_part = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;

        my $ifIndex =
            $results->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID} . '.' .  $ifKey_part
            };
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

sub setConnectedDevices {
    my ($results, $ports, $walks) = @_;

    if (ref $results->{cdpCacheAddress} eq 'HASH') {
        while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
            my $ip = hex2canonical($ip_hex);
            next if $ip eq '0.0.0.0';

            my $short_number = $number;
            $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my $connections =
                $ports->[$array[1]]->{CONNECTIONS};

            $connections->{CONNECTION}->{IP} = $ip;
            $connections->{CDP} = 1;
            $connections->{CONNECTION}->{IFDESCR} =
                $results->{cdpCacheDevicePort}->{
                    $walks->{cdpCacheDevicePort}->{OID} . $short_number
                };
        }
    }

    if (ref $results->{lldpCacheAddress} eq 'HASH') {
        while (my ($number, $chassisname) = each %{$results->{lldpCacheAddress}}) {
            my $short_number = $number;
            $short_number =~ s/$walks->{lldpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my $connections =
                $ports->[$array[1]]->{CONNECTIONS};

            # already done through CDP 
            next if $connections->{CDP};

            $connections->{CONNECTION}->{SYSNAME} = $chassisname;
            $connections->{CDP} = 1;
            $connections->{CONNECTION}->{IFDESCR} =
                $results->{lldpCacheDevicePort}->{
                    $walks->{lldpCacheDevicePort}->{OID} . $short_number
                };
        }
    }
}

1;
