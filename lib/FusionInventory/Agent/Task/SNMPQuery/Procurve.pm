package FusionInventory::Agent::Task::SNMPQuery::Procurve;

use strict;
use warnings;

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

    if (ref($results->{cdpCacheAddress}) eq "HASH"){
        while ( my ( $number, $ip_hex) = each (%{$results->{cdpCacheAddress}}) ) {
            $ip_hex =~ s/://g;
            $short_number = $number;
            $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my @ip_num = split(/(\S{2})/, $ip_hex);
            my $ip = (hex $ip_num[3]).".".(hex $ip_num[5]).".".(hex $ip_num[7]).".".(hex $ip_num[9]);
            if (($ip ne "0.0.0.0") && ($ip =~ /^([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])$/)){
                $port_number[$array[1]] = 1;
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IP} = $ip;
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
                if (defined($results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number})) {
                    $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $results->{cdpCacheDevicePort}->{$walks->{cdpCacheDevicePort}->{OID}.$short_number};
                }
            }
        }
    }
    if (ref($results->{lldpCacheAddress}) eq "HASH"){
        while ( my ( $number, $chassisname) = each (%{$results->{lldpCacheAddress}}) ) {
            $short_number = $number;
            $short_number =~ s/$walks->{lldpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            if (!defined($port_number[$array[1]])) {
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{SYSNAME} = $chassisname;
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
                if (defined($results->{lldpCacheDevicePort}->{$walks->{lldpCacheDevicePort}->{OID}.$short_number})) {
                    $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $results->{lldpCacheDevicePort}->{$walks->{lldpCacheDevicePort}->{OID}.$short_number};
                }

            }
        }
    }
}


1;
