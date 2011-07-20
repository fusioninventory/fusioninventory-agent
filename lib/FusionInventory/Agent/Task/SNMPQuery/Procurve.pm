package FusionInventory::Agent::Task::SNMPQuery::Procurve;

use strict;

sub GetMAC {
    my $HashDataSNMP = shift,
    my $datadevice = shift;
    my $self = shift;
    my $oid_walks = shift;

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
                if (not exists $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CDP}) {
                    my $add = 1;
                    if ($ifphysaddress eq "") {
                        $add = 0;
                    }
                    if ($ifphysaddress eq $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{MAC}) {
                        $add = 0;
                    }
                    if ($add eq "1") {
                        if (exists $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                            $i = @{$datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
                            #$i++;
                        } else {
                            $i = 0;
                        }
                        $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
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


sub CDPLLDPPorts {
    my $HashDataSNMP = shift,
    my $datadevice = shift;
    my $oid_walks = shift;
    my $self = shift;

    my $short_number;
    my @port_number;

    if (ref($HashDataSNMP->{cdpCacheAddress}) eq "HASH"){
        while ( my ( $number, $ip_hex) = each (%{$HashDataSNMP->{cdpCacheAddress}}) ) {
            $ip_hex =~ s/://g;
            $short_number = $number;
            $short_number =~ s/$oid_walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my @ip_num = split(/(\S{2})/, $ip_hex);
            my $ip = (hex $ip_num[3]).".".(hex $ip_num[5]).".".(hex $ip_num[7]).".".(hex $ip_num[9]);
            if (($ip ne "0.0.0.0") && ($ip =~ /^([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])\.([O1]?\d\d?|2[0-4]\d|25[0-5])$/)){
                $port_number[$array[1]] = 1;
                $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IP} = $ip;
                $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
                if (defined($HashDataSNMP->{cdpCacheDevicePort}->{$oid_walks->{cdpCacheDevicePort}->{OID}.$short_number})) {
                    $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $HashDataSNMP->{cdpCacheDevicePort}->{$oid_walks->{cdpCacheDevicePort}->{OID}.$short_number};
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
    if (ref($HashDataSNMP->{lldpCacheAddress}) eq "HASH"){
        while ( my ( $number, $chassisname) = each (%{$HashDataSNMP->{lldpCacheAddress}}) ) {
            $short_number = $number;
            $short_number =~ s/$oid_walks->{lldpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            if (!defined($port_number[$array[1]])) {
                $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{SYSNAME} = $chassisname;
                $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CDP} = "1";
                if (defined($HashDataSNMP->{lldpCacheDevicePort}->{$oid_walks->{lldpCacheDevicePort}->{OID}.$short_number})) {
                    $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$array[1]}]->{CONNECTIONS}->{CONNECTION}->{IFDESCR} = $HashDataSNMP->{lldpCacheDevicePort}->{$oid_walks->{lldpCacheDevicePort}->{OID}.$short_number};
                }

                delete $HashDataSNMP->{lldpCacheAddress}->{$number};
                if (ref($HashDataSNMP->{lldpCacheDevicePort}) eq "HASH"){
                    delete $HashDataSNMP->{lldpCacheDevicePort}->{$number};
                }
            }
        }
        if (keys (%{$HashDataSNMP->{lldpCacheAddress}}) eq "0") {
            delete $HashDataSNMP->{lldpCacheAddress};
        }
        if (ref($HashDataSNMP->{lldpCacheDevicePort}) eq "HASH"){
            if (keys (%{$HashDataSNMP->{lldpCacheDevicePort}}) eq "0") {
                delete $HashDataSNMP->{lldpCacheDevicePort};
            }
        }
    }
    return $datadevice, $HashDataSNMP;
}


1;
