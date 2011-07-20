package FusionInventory::Agent::Task::SNMPQuery::ThreeCom;

use strict;
use warnings;

sub GetMAC {
    my $HashDataSNMP = shift,
    my $datadevice = shift;
    my $portsindex = shift;
    my $oid_walks = shift;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;
    my $add = 0;
    my $i;

    while ( my ($number,$ifphysaddress) = each (%{$HashDataSNMP->{dot1dTpFdbAddress}}) ) {
        $short_number = $number;
        $short_number =~ s/$oid_walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $oid_walks->{dot1dTpFdbPort}->{OID};

        $add = 1;
        if ($ifphysaddress eq "") {
            $add = 0;
        }
        if (($add eq "1") && (exists($HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}))) {
            $ifIndex = $HashDataSNMP->{dot1dBasePortIfIndex}->{
            $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
            $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
            };

            if (exists $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                $i = @{$datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
            } else {
                $i = 0;
            }
            $datadevice->{PORTS}->{PORT}->[$portsindex->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
            $i++;
        }
    }
    return $datadevice, $HashDataSNMP;
}


# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my $datadevice = shift;
    my $portsindex = shift;

    $datadevice->{PORTS}->{PORT}->[$portsindex->{101}]->{MAC} = $datadevice->{PORTS}->{PORT}->[$portsindex->{1}]->{MAC};
    delete $datadevice->{PORTS}->{PORT}->[$portsindex->{1}];
    delete $datadevice->{PORTS}->{PORT}->[$portsindex->{101}]->{CONNECTIONS};
    return $datadevice;
}


1;
