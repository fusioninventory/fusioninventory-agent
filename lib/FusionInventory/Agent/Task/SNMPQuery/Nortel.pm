package FusionInventory::Agent::Task::SNMPQuery::Nortel;

use strict;
use warnings;

sub setTrunkPorts {
    my ($results, $datadevice, $ports) = @_;

    my $myports;

    while ( (my $oid, my $trunkname) = each (%{$results->{PortVlanIndex}}) ) {
        my @array = split(/\./, $oid);

        $myports->{$array[(@array - 2)]}->{$array[(@array - 1)]} = $trunkname;
    }

    while ( my ($portnumber,$vlans) = each (%{$myports}) ) {
        if (keys %{$vlans} > 1) {
            # Trunk
            $datadevice->{PORTS}->{PORT}->[$ports->{$portnumber}]->{TRUNK} = "1";
        } elsif (keys %{$vlans} eq "1") {
            # One  vlan
            while ( my ($vlan_id,$vlan_name) = each (%{$vlans}) ) {
                $datadevice->{PORTS}->{PORT}->[$ports->{$portnumber}]->{VLANS}->{VLAN}->[0]->{NAME} = $vlan_name;
                $datadevice->{PORTS}->{PORT}->[$ports->{$portnumber}]->{VLANS}->{VLAN}->[0]->{NUMBER} = $vlan_id;
            }
        }
    }
}


sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;

    my $i = 0;

    while ( my ($number,$ifphysaddress) = each (%{$results->{dot1dTpFdbAddress}}) ) {
        $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};
        if (exists $results->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}) {
            if (exists $results->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID}.".".
                $results->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                }) {

                $ifIndex = $results->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID}.".".
                $results->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                };
                if (not exists $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CDP}) {
                    my $add = 1;
                    if ($ifphysaddress eq "") {
                        $add = 0;
                    }
                    if ($ifphysaddress eq $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{MAC}) {
                        $add = 0;
                    }
                    if ($add eq "1") {
                        if (exists $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                            $i = @{$datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
                            #$i++;
                        } else {
                            $i = 0;
                        }
                        $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
                        $i++;
                    }
                }
            }
        }
    }
}


sub setCDPPorts {
    my ($results, $datadevice, $walks, $ports) = @_;

    my $short_number;
    my @port_number;

    if (ref($results->{lldpRemChassisId}) eq "HASH"){
        while ( my ( $number, $chassisname) = each (%{$results->{lldpRemChassisId}}) ) {
            $short_number = $number;
            $short_number =~ s/$walks->{lldpRemChassisId}->{OID}//;
            my @array = split(/\./, $short_number);
            if (!defined($port_number[$array[2]])) {
                my @arraymac = split(/(\S{2})/, $chassisname);
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[2]}]->{CONNECTIONS}->{CONNECTION}->{SYSMAC} = $arraymac[3].":".$arraymac[5].":".$arraymac[7].":".$arraymac[9].":".$arraymac[11].":".$arraymac[13];
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[2]}]->{CONNECTIONS}->{CDP} = "1";
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[2]}]->{CONNECTIONS}->{CONNECTION}->{IFNUMBER} = $array[3];

            }
        }
    }
}


1;
