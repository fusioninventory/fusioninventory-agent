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
__END__

=head1 NAME

FusionInventory::Agent::Task::Manufacturer::3Com - 3Com-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to 3Com hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddress($results, $ports, $walks)

Set mac addresses of connected devices.

=head2 RewritePortOf225($results, $ports, $walk)
