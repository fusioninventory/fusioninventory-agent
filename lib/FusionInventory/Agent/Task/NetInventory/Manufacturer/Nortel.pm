package FusionInventory::Agent::Task::NetInventory::Manufacturer::Nortel;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;

sub setConnectedDevicesMacAddress {
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

sub setTrunkPorts {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};

    my $myports;

    while (my ($oid, $trunkname) = each %{$results->{PortVlanIndex}}) {
        my @array = split(/\./, $oid);
        $myports->{$array[-2]}->{$array[-1]} = $trunkname;
    }

    while (my ($portnumber, $vlans) = each %{$myports}) {
        if (keys %{$vlans} == 1) {
            # a single vlan
            while (my ($id, $name) = each %{$vlans}) {
                $ports->{$ports->{$portnumber}}->{VLANS}->{VLAN}->[0] = {
                    NAME   => $name,
                    NUMBER => $id
                };
            }
        } else {
            # trunk
            $ports->{$ports->{$portnumber}}->{TRUNK} = 1;
        }
    }
}

sub setConnectedDevices {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};
    my $walks   = $params{walks};

    return unless ref $results->{lldpRemChassisId} eq "HASH";

    while (my ($number, $chassisname) = each %{$results->{lldpRemChassisId}}) {
        my $short_number = $number;
        $short_number =~ s/$walks->{lldpRemChassisId}->{OID}//;

        my @array = split(/\./, $short_number);
        my $connections =
            $ports->{$array[2]}->{CONNECTIONS};

        $connections->{CONNECTION}->{IFNUMBER} = $array[3];
        $connections->{CONNECTION}->{SYSMAC} =
            alt2canonical($chassisname);
        $connections->{CDP} = 1;
    }
}

1;
=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer::Nortel - Nortel-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Nortel hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddress(%params)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back

=head2 setTrunkPorts(%params)

Set trunk bit on relevant ports.

=over

=item results raw values collected through SNMP

=item ports device ports list

=back

=head2 setConnectedDevices(%params)

Set connected devices, through CDP or LLDP.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=back
