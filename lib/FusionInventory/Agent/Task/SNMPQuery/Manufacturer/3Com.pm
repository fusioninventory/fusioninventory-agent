package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::3Com;

use strict;
use warnings;

sub setMacAddresses {
    my ($results, $datadevice, $ports, $walks) = @_;

    while (my ($number, $ifphysaddress) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $ifphysaddress;

        my $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $short_number;
        my $ifIndex = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifIndex;

        my $port = $datadevice->{PORTS}->{PORT}->[$ports->{$ifIndex}];
        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my ($results, $datadevice, $ports, $walks) = @_;

    my $deviceports = $datadevice->{PORTS}->{PORT};
    $deviceports->[$ports->{101}]->{MAC} = $deviceports->[$ports->{1}]->{MAC};
    delete $deviceports->[$ports->{1}];
    delete $deviceports->[$ports->{101}]->{CONNECTIONS};
}

1;
