package FusionInventory::Agent::Task::SNMPQuery::Cisco;

use strict;
use warnings;

sub TrunkPorts {
    my ($HashDataSNMP, $datadevice, $portsindex) = @_;

    while ( (my $port_id, my $trunk) = each (%{$HashDataSNMP->{vlanTrunkPortDynamicStatus}}) ) {
        if ($trunk eq "1") {
            $datadevice->{PORTS}->{PORT}->[$portsindex->{lastSplitObject($port_id)}]->{TRUNK} = $trunk;
        } else {
            $datadevice->{PORTS}->{PORT}->[$portsindex->{lastSplitObject($port_id)}]->{TRUNK} = '0';
        }
        delete $HashDataSNMP->{vlanTrunkPortDynamicStatus}->{$port_id};
    }
    if (keys (%{$HashDataSNMP->{vlanTrunkPortDynamicStatus}}) eq "0") {
        delete $HashDataSNMP->{vlanTrunkPortDynamicStatus};
    }
    return $datadevice, $HashDataSNMP;
}



sub CDPPorts {
    my ($HashDataSNMP, $datadevice, $oid_walks, $portsindex) = @_;

    my $short_number;

    if (ref($HashDataSNMP->{cdpCacheAddress}) eq "HASH"){
        while ( my ( $number, $ip_hex) = each (%{$HashDataSNMP->{cdpCacheAddress}}) ) {
            $ip_hex =~ s/://g;
            $short_number = $number;
            $short_number =~ s/$oid_walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my @ip_num = split(/(\S{2})/, $ip_hex);
            my $ip = (hex $ip_num[3]).".".(hex $ip_num[5]).".".(hex $ip_num[7]).".".(hex $ip_num[9]);
            if ($ip ne "0.0.0.0") {
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IP} = $ip;
                $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
                if (defined($HashDataSNMP->{cdpCacheDevicePort}->{$oid_walks->{cdpCacheDevicePort}->{OID}.$short_number})) {
                    $datadevice->{PORTS}->{PORT}->[$portsindex->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $HashDataSNMP->{cdpCacheDevicePort}->{$oid_walks->{cdpCacheDevicePort}->{OID}.$short_number};
                }
            }
            delete $HashDataSNMP->{cdpCacheAddress}->{$number};
            if (ref($HashDataSNMP->{cdpCacheDevicePort}) eq "HASH"){
                delete $HashDataSNMP->{cdpCacheDevicePort}->{$number};
            }
        }
        if (keys (%{$HashDataSNMP->{cdpCacheAddress}}) eq "0") {
            delete $HashDataSNMP->{cdpCacheAddress};
        }
        if (ref($HashDataSNMP->{cdpCacheDevicePort}) eq "HASH"){
            if (keys (%{$HashDataSNMP->{cdpCacheDevicePort}}) eq "0") {
                delete $HashDataSNMP->{cdpCacheDevicePort};
            }
        }
    }
    return $datadevice, $HashDataSNMP;
}



sub GetMAC {
    my ($HashDataSNMP, $datadevice, $vlan_id, $portsindex, $oid_walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;

    my $i = 0;
    # each VLAN WALK per port
    while ( my ($number,$ifphysaddress) = each (%{$HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbAddress}}) ) {
        $short_number = $number;
        $short_number =~ s/$oid_walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $oid_walks->{dot1dTpFdbPort}->{OID};
        if (exists $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}) {
            if (exists $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{
                $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                }) {

                $ifIndex = $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{
                $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
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
#      delete $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbAddress}->{$number};
#      delete $HashDataSNMP->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number};
    }
    return $datadevice, $HashDataSNMP;
}



sub lastSplitObject {
    my $var = shift;

    my @array = split(/\./, $var);
    return $array[-1];
}

1;
