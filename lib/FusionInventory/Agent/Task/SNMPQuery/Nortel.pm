package FusionInventory::Agent::Task::SNMPQuery::Nortel;

use strict;
use warnings;

sub VlanTrunkPorts {
    my ($HashDataSNMP, $datadevice, $portsindex) = @_;

    my $ports;

    while ( (my $oid, my $trunkname) = each (%{$HashDataSNMP->{PortVlanIndex}}) ) {
        my @array = split(/\./, $oid);

        $ports->{$array[(@array - 2)]}->{$array[(@array - 1)]} = $trunkname;
    }

    while ( my ($portnumber,$vlans) = each (%{$ports}) ) {
        if (keys %{$vlans} > 1) {
            # Trunk
            $datadevice->{PORTS}->{PORT}->[$portsindex->{$portnumber}]->{TRUNK} = "1";
        } elsif (keys %{$vlans} eq "1") {
            # One  vlan
            while ( my ($vlan_id,$vlan_name) = each (%{$vlans}) ) {
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$portnumber}]->{VLANS}->{VLAN}->[0]->{NAME} = $vlan_name;
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$portnumber}]->{VLANS}->{VLAN}->[0]->{NUMBER} = $vlan_id;
            }
        }
    }
    return $datadevice, $HashDataSNMP;
}


sub GetMAC {
    my ($HashDataSNMP, $datadevice, $portsindex, $oid_walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;

    my $i = 0;

    while ( my ($number,$ifphysaddress) = each (%{$HashDataSNMP->{dot1dTpFdbAddress}}) ) {
        $short_number = $number;
        $short_number =~ s/$oid_walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $oid_walks->{dot1dTpFdbPort}->{OID};
        if (exists $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}) {
            if (exists $HashDataSNMP->{dot1dBasePortIfIndex}->{
                $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                }) {

                $ifIndex = $HashDataSNMP->{dot1dBasePortIfIndex}->{
                $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                };
                if (not exists $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CDP}) {
                    my $add = 1;
                    if ($ifphysaddress eq "") {
                        $add = 0;
                    }
                    if ($ifphysaddress eq $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{MAC}) {
                        $add = 0;
                    }
                    if ($add eq "1") {
                        if (exists $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                            $i = @{$datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
                            #$i++;
                        } else {
                            $i = 0;
                        }
                        $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
                        $i++;
                    }
                }
            }
        }
        delete $HashDataSNMP->{dot1dTpFdbAddress}->{$number};
        delete $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number};
    }
    return $datadevice, $HashDataSNMP;
}


sub LLDPPorts {
    my ($HashDataSNMP, $datadevice, $oid_walks, $portsindex) = @_;

    my $short_number;
    my @port_number;

    if (ref($HashDataSNMP->{lldpRemChassisId}) eq "HASH"){
        while ( my ( $number, $chassisname) = each (%{$HashDataSNMP->{lldpRemChassisId}}) ) {
            $short_number = $number;
            $short_number =~ s/$oid_walks->{lldpRemChassisId}->{OID}//;
            my @array = split(/\./, $short_number);
            if (!defined($port_number[$array[2]])) {
                my @arraymac = split(/(\S{2})/, $chassisname);
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[2]}]->{CONNECTIONS}->{CONNECTION}->{SYSMAC} = $arraymac[3].":".$arraymac[5].":".$arraymac[7].":".$arraymac[9].":".$arraymac[11].":".$arraymac[13];
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[2]}]->{CONNECTIONS}->{CDP} = "1";
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[2]}]->{CONNECTIONS}->{CONNECTION}->{IFNUMBER} = $array[3];

                delete $HashDataSNMP->{lldpRemChassisId}->{$number};
                if (ref($HashDataSNMP->{lldpRemPortId}) eq "HASH"){
                    delete $HashDataSNMP->{lldpRemPortId}->{$number};
                }
            }
        }
        if (keys (%{$HashDataSNMP->{lldpRemChassisId}}) eq "0") {
            delete $HashDataSNMP->{lldpRemChassisId};
        }
        if (ref($HashDataSNMP->{lldpRemPortId}) eq "HASH"){
            if (keys (%{$HashDataSNMP->{lldpRemPortId}}) eq "0") {
                delete $HashDataSNMP->{lldpRemPortId};
            }
        }
    }
    return $datadevice, $HashDataSNMP;
}


1;
