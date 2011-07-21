package FusionInventory::Agent::Task::SNMPQuery::Cisco;

use strict;
use warnings;

use FusionInventory::Agent::Task::SNMPQuery::Tools;

sub setMacAddresses {
    my ($results, $datadevice, $vlan_id, $ports, $walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;

    my $i = 0;
    # each VLAN WALK per port
    while (my ($number, $ifphysaddress) = each %{$results->{VLAN}->{$vlan_id}->{dot1dTpFdbAddress}}) {
        $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};
        if (exists $results->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}) {
            if (exists $results->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID}.".".
                $results->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                }) {

                $ifIndex = $results->{VLAN}->{$vlan_id}->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID}.".".
                $results->{VLAN}->{$vlan_id}->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
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

sub setTrunkPorts {
    my ($results, $deviceports, $ports) = @_;

    while (my ($port_id, $trunk) = each %{$results->{vlanTrunkPortDynamicStatus}}) {
        $deviceports->[$ports->{lastSplitObject($port_id)}]->{TRUNK} = $trunk ? 1 : 0;
    }
}

sub setCDPPorts {
    my ($results, $datadevice, $walks, $ports) = @_;

    return unless ref $results->{cdpCacheAddress} eq 'HASH';

    my $short_number;

    while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
        $ip_hex =~ s/://g;
        $short_number = $number;
        $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
        my @array = split(/\./, $short_number);
        my @ip_num = split(/(\S{2})/, $ip_hex);
        my $ip = (hex $ip_num[3]).".".(hex $ip_num[5]).".".(hex $ip_num[7]).".".(hex $ip_num[9]);
        if ($ip ne "0.0.0.0") {
            $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IP} = $ip;
            $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
            if (defined($results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number})) {
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number};
            }
        }
    }
}

1;
