package FusionInventory::Agent::Task::NetInventory::Manufacturer::3Com;

use strict;
use warnings;

sub setConnectedDevicesMacAddress {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    while (my ($oid, $mac) = each %{$results->{dot1dTpFdbAddress}}) {
        next unless $mac;

        my $suffix = $oid;
        $suffix =~ s/$walks->{dot1dTpFdbAddress}->{OID}//;
        my $dot1dTpFdbPort = $walks->{dot1dTpFdbPort}->{OID};

        my $portKey = $dot1dTpFdbPort . $suffix;
        my $ifIndex = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifIndex;

        my $port = $ports->{$ifIndex};

        # create a new connection with this mac address
        my $connections = $port->{CONNECTIONS}->{CONNECTION};
        push @$connections, { MAC => $mac };
    }
}

# In Intellijack 225, put mac address of port 'IntelliJack Ethernet Adapter' in port 'LAN Port'
sub RewritePortOf225 {
    my (%params) = @_;

    my $ports = $params{ports};

    $ports->{101}->{MAC} = $ports->{1}->{MAC};
    delete $ports->{1};
    delete $ports->{101}->{CONNECTIONS};
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer::3Com - 3Com-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to 3Com hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddress(%params)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 RewritePortOf225(%params)

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
