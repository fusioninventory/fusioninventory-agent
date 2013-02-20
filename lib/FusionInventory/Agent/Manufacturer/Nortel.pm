package FusionInventory::Agent::Manufacturer::Nortel;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::SNMP;

sub setTrunkPorts {
    my (%params) = @_;

    my $results = $params{results};
    my $ports   = $params{ports};

    my $myports;

    while (my ($oid, $vlan) = each %{$results->{PortVlanIndex}}) {
        $myports->{getElement($oid, -2)}->{getElement($oid, -1)} = $vlan;
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

    while (my ($oid, $chassisname) = each %{$results->{lldpRemChassisId}}) {
        my $suffix = $oid;
        $suffix =~ s/$walks->{lldpRemChassisId}->{OID}//;

        my $connections =
            $ports->{getElement($suffix, 2)}->{CONNECTIONS};

        $connections->{CONNECTION}->{IFNUMBER} = getElement($suffix, 3);
        $connections->{CONNECTION}->{SYSMAC} =
            alt2canonical($chassisname);
        $connections->{CDP} = 1;
    }
}

1;
=head1 NAME

FusionInventory::Agent::Manufacturer::Nortel - Nortel-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Nortel hardware.

=head1 FUNCTIONS

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
