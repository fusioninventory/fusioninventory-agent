package FusionInventory::Agent::Task::NetInventory::Manufacturer::Juniper;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::SNMP qw(getElement getLastElement getNextToLastElement);

sub setConnectedDevicesMacAddress {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    while (my ($oid, $suffix) = each %{$results->{dot1dTpFdbAddress}}) {

        my $mac = sprintf("%02x:%02x:%02x:%02x:%02x:%02x", getElement($oid, -6),
                          getElement($oid, -5),
                          getElement($oid, -4),
                          getElement($oid, -3),
                          getElement($oid, -2),
                          getElement($oid, -1));

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

        # This mac is empty
        next unless $mac;

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

            my $port_number =
                getNextToLastElement($oid) . "." . getLastElement($oid, -1);

            $ports->{getNextToLastElement($oid)}->{CONNECTIONS} = {
                CDP        => 1,
                CONNECTION => {
                    IP      => $ip,
                    IFDESCR => $results->{cdpCacheDevicePort}->{
                        $walks->{cdpCacheDevicePort}->{OID} . "." . $port_number
                    },
                    SYSDESCR => $results->{cdpCacheVersion}->{
                        $walks->{cdpCacheVersion}->{OID} . "." . $port_number
                    },
                    SYSNAME  => $results->{cdpCacheDeviceId}->{
                        $walks->{cdpCacheDeviceId}->{OID} . "." . $port_number
                    },
                    MODEL => $results->{cdpCachePlatform}->{
                        $walks->{cdpCachePlatform}->{OID} . "." . $port_number
                    }
                }
            };
        }
    } elsif (ref $results->{lldpRemChassisId} eq 'HASH') {
        while (my ($oid, $sysmac) = each %{$results->{lldpRemChassisId}}) {

            my $port_number =
                getElement($oid, -3) . "." . getNextToLastElement($oid) . "." . getLastElement($oid, -1);

            $ports->{getNextToLastElement($oid)}->{CONNECTIONS} = {
                CDP        => 1,
                CONNECTION => {
                    SYSMAC => alt2canonical($sysmac),
                    IFDESCR => $results->{lldpRemPortDesc}->{
                        $walks->{lldpRemPortDesc}->{OID} . "." . $port_number
                    },
                    SYSDESCR => $results->{lldpRemSysDesc}->{
                        $walks->{lldpRemSysDesc}->{OID} . "." . $port_number
                    },
                    SYSNAME  => $results->{lldpRemSysName}->{
                        $walks->{lldpRemSysName}->{OID} . "." . $port_number
                    },
                    IFNUMBER => $results->{lldpRemPortId}->{
                        $walks->{lldpRemPortId}->{OID} . "." . $port_number
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
