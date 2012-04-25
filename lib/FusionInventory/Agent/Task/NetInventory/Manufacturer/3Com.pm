package FusionInventory::Agent::Task::NetInventory::Manufacturer::3Com;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

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

        $mac = alt2canonical($mac);

        # this is port own mac address
        next if $port->{MAC} && $port->{MAC} eq $mac;

        # This mac is empty
        next if $mac eq '';

        # create a new connection with this mac address
        push
            @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}},
            $mac;
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
