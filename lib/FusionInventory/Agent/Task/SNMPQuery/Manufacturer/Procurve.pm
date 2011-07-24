package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Procurve;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

sub setMacAddresses {
    my ($results, $deviceports, $index, $walks) = @_;

    while (my ($number, $ifphysaddress) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $ifphysaddress;

        my $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $short_number;
        my $ifKey_part = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;

        my $ifIndex =
            $results->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID} . '.' .  $ifKey_part
            };
        next unless defined $ifIndex;

        my $port = $deviceports->[$index->{$ifIndex}];

        next if exists $port->{CONNECTIONS}->{CDP};
        next if $ifphysaddress eq $port->{MAC};

        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

sub setConnectedDevices {
    my ($results, $deviceports, $index, $walks) = @_;

    if (ref $results->{cdpCacheAddress} eq 'HASH') {
        while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
            my $ip = hex2quad($ip_hex);
            next if $ip eq '0.0.0.0';

            my $short_number = $number;
            $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my $connections =
                $deviceports->[$index->{$array[1]}]->{CONNECTIONS};

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
                $deviceports->[$index->{$array[1]}]->{CONNECTIONS};

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
