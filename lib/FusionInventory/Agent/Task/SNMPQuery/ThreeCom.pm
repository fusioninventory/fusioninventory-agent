package FusionInventory::Agent::Task::SNMPQuery::ThreeCom;

use strict;
use warnings;

sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks) = @_;

    my $ifIndex;
    my $numberip;
    my $mac;
    my $short_number;
    my $dot1dTpFdbPort;
    my $add = 0;
    my $i;

    while ( my ($number,$ifphysaddress) = each (%{$results->{dot1dTpFdbAddress}}) ) {
        $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        $add = 1;
        if ($ifphysaddress eq "") {
            $add = 0;
        }
        if (($add eq "1") && (exists($results->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}))) {
            $ifIndex = $results->{dot1dBasePortIfIndex}->{
            $walks->{dot1dBasePortIfIndex}->{OID}.".".
            $results->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
            };

            if (exists $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                $i = @{$datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
            } else {
                $i = 0;
            }
            $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
            $i++;
        }
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my ($datadevice, $ports) = @_;

    $datadevice->{PORTS}->{PORT}->[$ports->{101}]->{MAC} = $datadevice->{PORTS}->{PORT}->[$ports->{1}]->{MAC};
    delete $datadevice->{PORTS}->{PORT}->[$ports->{1}];
    delete $datadevice->{PORTS}->{PORT}->[$ports->{101}]->{CONNECTIONS};
}

1;
