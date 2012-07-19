package FusionInventory::Agent::Manufacturer::Juniper;

use strict;
use warnings;

use FusionInventory::Agent::Tools::SNMP;

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    while (my ($oid, $suffix) = each %{$results->{dot1dTpFdbAddress}}) {
        my $mac =
            sprintf "%02x:%02x:%02x:%02x:%02x:%02x", getElements($oid, -6, -1);
        next unless $mac;

        # get port key
        my $portKey = $walks->{dot1dTpFdbPort}->{OID} . '.' . $suffix;

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

FusionInventory::Agent::Manufacturer::Juniper - Juniper-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Juniper hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddresses(%params)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
