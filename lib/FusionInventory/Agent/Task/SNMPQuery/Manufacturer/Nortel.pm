package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Nortel;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer';

use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddress {
    my ($class, $results, $ports, $walks) = @_;

    my $i = 0;
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

        my $port = $ports->[$ifIndex];

        next if exists $port->{CONNECTIONS}->{CDP};
        next if $ifphysaddress eq $port->{MAC};

        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

sub setTrunkPorts {
    my ($class, $results, $ports, $ports) = @_;

    my $myports;

    while (my ($oid, $trunkname) = each %{$results->{PortVlanIndex}}) {
        my @array = split(/\./, $oid);
        $myports->{$array[-2]}->{$array[-1]} = $trunkname;
    }

    while (my ($portnumber, $vlans) = each %{$myports}) {
        if (keys %{$vlans} == 1) {
            # a single vlan
            while (my ($id, $name) = each %{$vlans}) {
                $ports->[$ports->{$portnumber}]->{VLANS}->{VLAN}->[0] = {
                    NAME   => $name,
                    NUMBER => $id
                };
            }
        } else {
            # trunk
            $ports->[$ports->{$portnumber}]->{TRUNK} = 1;
        }
    }
}

sub setConnectedDevices {
    my ($class, $results, $ports, $walks) = @_;

    return unless ref $results->{lldpRemChassisId} eq "HASH";

    while (my ($number, $chassisname) = each %{$results->{lldpRemChassisId}}) {
        my $short_number = $number;
        $short_number =~ s/$walks->{lldpRemChassisId}->{OID}//;

        my @array = split(/\./, $short_number);
        my $connections =
            $ports->[$array[2]]->{CONNECTIONS};

        $connections->{CONNECTION}->{IFNUMBER} = $array[3];
        $connections->{CONNECTION}->{SYSMAC} =
            join2split($chassisname);
        $connections->{CDP} = 1;
    }
}

1;
