package FusionInventory::Agent::Task::NetInventory::Manufacturer;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    while (my ($oid, $mac) = each %{$results->{dot1dTpFdbAddress}}) {
        $mac = alt2canonical($mac);
        next unless $mac;

        # get port key
        my $portKey_part = $oid;
        $portKey_part =~ s/$walks->{dot1dTpFdbAddress}->{OID}\.//;
        next unless $portKey_part;
        my $portKey = $walks->{dot1dTpFdbPort}->{OID} . '.' . $portKey_part;

        # get interface key from port key
        my $ifKey_part = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;
        my $ifKey = $walks->{dot1dBasePortIfIndex}->{OID} . '.' . $ifKey_part;

        # get interface index
        my $ifIndex = $results->{dot1dBasePortIfIndex}->{$ifKey};
        next unless defined $ifIndex;

        my $port = $ports->{$ifIndex};

        # this device has already been processed through CDP/LLDP
        next if $port->{CONNECTIONS}->{CDP};

        # this is port own mac address
        next if $port->{MAC} eq $mac;

        # create a new connection with this mac address
        push
            @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}},
            $mac;
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer -
Manufacturer-specific methods

=head1 DESCRIPTION

This is the base class defining interface for all manufacturer-specific methods.

=head1 METHODS

=head2 setConnectedDevicesMacAddresses(%params)

set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

