package FusionInventory::Agent::Task::NetInventory::Manufacturer::Procurve;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::SNMP qw(getLastElement getNextToLastElement);
    
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

        $mac = alt2canonical($mac);

        # this is port own mac address
        next if $port->{MAC} eq $mac;

        # create a new connection with this mac address
        push
            @{$port->{CONNECTIONS}->{CONNECTION}->{MAC}},
            $mac;
    }
}

sub setConnectedDevices {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    if (ref $results->{cdpCacheAddress} eq 'HASH') {
        while (my ($oid, $ip_hex) = each %{$results->{cdpCacheAddress}}) {
            my $ip = hex2canonical($ip_hex);
            next if $ip eq '0.0.0.0';

            my $port_number = getNextToLastElement($oid);

            $ports->{$port_number}->{CONNECTIONS} = {
                CDP        => 1,
                CONNECTION => {
                    IP      => $ip,
                    IFDESCR => $results->{cdpCacheDevicePort}->{
                        $walks->{cdpCacheDevicePort}->{OID} . $port_number
                    }
                }
            };
        }
    }

    if (ref $results->{lldpCacheAddress} eq 'HASH') {
        while (my ($oid, $chassisname) = each %{$results->{lldpCacheAddress}}) {

            my $port_number =
                getNextToLastElement($oid) . "." . getLastElement($oid, -1);

            # already done through CDP 
            next if $ports->{getNextToLastElement($oid)}->{CONNECTIONS};

            $ports->{getNextToLastElement($oid)}->{CONNECTIONS} = {
                CDP        => 1,
                CONNECTION => {
                    SYSNAME => $chassisname,
                    IFDESCR => $results->{lldpCacheDevicePort}->{
                        $walks->{lldpCacheDevicePort}->{OID} . "." . $port_number
                    }
                }
            };
        }
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer::Procurve - Procurve-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Procurve hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddress(%params)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setConnectedDevices(%params)

Set connected devices, through CDP or LLDP.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
