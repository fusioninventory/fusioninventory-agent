package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Procurve;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;

    my $i = 0;

    while (my ($number,$ifphysaddress) = each %{$results->{dot1dTpFdbAddress}}) {
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

    if (ref $results->{cdpCacheAddress} eq "HASH"){
        while (my ($number, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
            my $ip = hex2quad($ip_hex);
            next if $ip eq '0.0.0.0';

            my $short_number = $number;
            $short_number =~ s/$walks->{cdpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my $connections =
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS};

            $connections->{CONNECTION}->{IP} = $ip;
            $connections->{CDP} = 1;
            $connections->{CONNECTION}->{IFDESCR} =
                $results->{cdpCacheDevicePort}->{
                    $walks->{cdpCacheDevicePort}->{OID} . $short_number
                };
        }
    }
    if (ref $results->{lldpCacheAddress} eq "HASH"){
        while (my ($number, $chassisname) = each %{$results->{lldpCacheAddress}}) {
            my $short_number = $number;
            $short_number =~ s/$walks->{lldpCacheAddress}->{OID}//;
            my @array = split(/\./, $short_number);
            my $connections =
                $datadevice->{PORTS}->{PORT}->[$ports->{$array[1]}]->{CONNECTIONS};

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
