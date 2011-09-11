package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::3Com;

use strict;
use warnings;

sub setConnectedDevicesMacAddress {
    my ($results, $ports, $walks) = @_;

    while (my ($oid, $mac) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $mac;

        my $suffix = $oid;
        $suffix =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $suffix;
        my $ifIndex = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifIndex;

        my $port = $ports->[$ifIndex];

        # create a new connection with this mac address
        my $connections = $port->{CONNECTIONS}->{CONNECTION};
        push @$connections, { MAC => $mac };
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my ($results, $ports, $walks) = @_;

    $ports->[101]->{MAC} = $ports->[1]->{MAC};
    delete $ports->[1];
    delete $ports->[101]->{CONNECTIONS};
}

1;
