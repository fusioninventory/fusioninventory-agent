package FusionInventory::Agent::Task::SNMPQuery::Manufacturer::AlliedTelesis;

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
        my $ifKey_part = $results->{dot1dTpFdbPort}->{$portKey};
        next unless defined $ifKey_part;

        my $ifIndex =
            $results->{dot1dBasePortIfIndex}->{
                $walks->{dot1dBasePortIfIndex}->{OID} . '.' .  $ifKey_part
            };
        next unless defined $ifIndex;

        my $port = $ports->{$ifIndex};

        # this device has already been processed through CDP/LLDP
        next if $port->{CONNECTIONS}->{CDP};
        # this is port own mac address
        next if $port->{MAC} eq $mac;

        # create a new connection with this mac address
        my $connections = $port->{CONNECTIONS}->{CONNECTION};
        push @$connections, { MAC => $mac };
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Manufacturer::AlliedTelesis - AlliedTelesis-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to AlliedTelesis hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddress($results, $ports, $walks)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
