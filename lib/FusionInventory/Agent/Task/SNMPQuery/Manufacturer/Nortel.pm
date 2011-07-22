package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Nortel;

use strict;
use warnings;

sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks) = @_;

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

    my $myports;

    while (my ($oid, $trunkname) = each %{$results->{PortVlanIndex}}) {
        my @array = split(/\./, $oid);
        $myports->{$array[-2]}->{$array[-1]} = $trunkname;
    }

    while (my ($portnumber, $vlans) = each %{$myports}) {
        if (keys %{$vlans} == 1) {
            # a single vlan
            while (my ($id, $name) = each %{$vlans}) {
                $deviceports->[$ports->{$portnumber}]->{VLANS}->{VLAN}->[0] = {
                    NAME   => $name,
                    NUMBER => $id
                };
            }
        } else {
            # trunk
            $deviceports->[$ports->{$portnumber}]->{TRUNK} = 1;
        }
    }
}

sub setCDPPorts {
    my ($results, $datadevice, $walks, $ports) = @_;

    return unless ref $results->{lldpRemChassisId} eq "HASH";

    while (my ($number, $chassisname) = each %{$results->{lldpRemChassisId}}) {
        my $short_number = $number;
        $short_number =~ s/$walks->{lldpRemChassisId}->{OID}//;

        my @arraymac = split(/(\S{2})/, $chassisname);
        my @array = split(/\./, $short_number);
        my $connections =
            $datadevice->{PORTS}->{PORT}->[$ports->{$array[2]}]->{CONNECTIONS};

        $connections->{CONNECTION}->{IFNUMBER} = $array[3];
        $connections->{CONNECTION}->{SYSMAC} =
            $arraymac[3]  . ":" .
            $arraymac[5]  . ":" .
            $arraymac[7]  . ":" .
            $arraymac[9]  . ":" .
            $arraymac[11] . ":" .
            $arraymac[13];
        $connections->{CDP} = "1";
    }
}

1;
