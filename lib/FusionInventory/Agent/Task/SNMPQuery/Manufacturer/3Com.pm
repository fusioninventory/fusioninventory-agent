package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::3Com;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer';

sub setConnectedDevicesMacAddress {
    my ($class, $results, $ports, $walks) = @_;

    while (my ($number, $ifphysaddress) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $ifphysaddress;

        my $short_number = $number;
        $short_number =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $short_number;
        my $ifIndex = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifIndex;

        my $port = $ports->[$ifIndex];
        my $connection = $port->{CONNECTIONS}->{CONNECTION};
        my $i = $connection ? @{$connection} : 0;
        $connection->[$i]->{MAC} = $ifphysaddress;
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my ($class, $results, $ports, $walks) = @_;

    $ports->[101]->{MAC} = $ports->[1]->{MAC};
    delete $ports->[1];
    delete $ports->[101]->{CONNECTIONS};
}

1;
