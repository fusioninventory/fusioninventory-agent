package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Nortel;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer';

use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddress {
    my ($class, $results, $ports, $walks) = @_;

    my $i = 0;
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

sub setTrunkPorts {
    my ($class, $results, $ports) = @_;

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
            alt2canonical($chassisname);
        $connections->{CDP} = 1;
    }
}

1;
