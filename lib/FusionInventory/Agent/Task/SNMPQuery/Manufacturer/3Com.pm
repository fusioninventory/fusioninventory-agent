package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::3Com;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer';

sub setMacAddresses {
    my ($class, $results, $deviceports, $walks) = @_;

    while (my ($number, $ifphysaddress) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $ifphysaddress;

        my $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $short_number;
        my $ifIndex = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifIndex;

        my $port = $deviceports->[$ifIndex];
        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my ($class, $results, $deviceports, $walks) = @_;

    $deviceports->[101]->{MAC} = $deviceports->[1]->{MAC};
    delete $deviceports->[1];
    delete $deviceports->[101]->{CONNECTIONS};
}

1;
