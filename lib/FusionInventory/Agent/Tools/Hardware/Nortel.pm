package FusionInventory::Agent::Tools::Hardware::Nortel;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Hardware;
use FusionInventory::Agent::Tools::Network;

sub setTrunkPorts {
    my (%params) = @_;

    my $snmp  = $params{snmp};
    my $model = $params{model};
    my $ports = $params{ports};

    my $vlanIndex = $snmp->walk($model->{oids}->{PortVlanIndex});

    my $myports;

    # each result matches the following scheme:
    # $prefix.x.y = $value
    # whereas x is the port number, y the vlan number, $value the vlan name

    while (my ($suffix, $vlan_name) = sort each %{$vlanIndex}) {
        my $port_id = getElement($suffix, -2);
        my $vlan_id = getElement($suffix, -1);
        $myports->{$port_id}->{$vlan_id} = $vlan_name;
    }

    while (my ($port_id, $vlans) = sort each %{$myports}) {
        if (keys %{$vlans} == 1) {
            # a single vlan
            while (my ($id, $name) = sort each %{$vlans}) {
                $ports->{$port_id}->{VLANS}->{VLAN}->[0] = {
                    NAME   => $name,
                    NUMBER => $id
                };
            }
        } else {
            # trunk
            $ports->{$port_id}->{TRUNK} = 1;
        }
    }
}

sub setConnectedDevicesInfo {
    my (%params) = @_;

    my $snmp   = $params{snmp};
    my $model  = $params{model};
    my $ports  = $params{ports};
    my $logger = $params{logger};

    my $lldpRemChassisId = $snmp->walk($model->{oids}->{lldpRemChassisId});

    # each lldp variable matches the following scheme:
    # $prefix.x.y.z = $value
    # whereas y is the port number

    while (my ($suffix, $mac) = each %{$lldpRemChassisId}) {
        my $port_id = getElements($suffix, -2);

        # safety check
        if (!$ports->{$port_id}) {
            $logger->error("non-existing port $port_id, check lldpRemChassisId mapping")
                if $logger;
            last;
        }

        $ports->{$port_id}->{CONNECTIONS} = {
            CDP        => 1,
            CONNECTION => {
                SYSMAC   => scalar alt2canonical($mac),
                IFNUMBER => getElement($suffix, 3),
            }
        };
    }
}

1;
=head1 NAME

FusionInventory::Agent::Tools::Hardware::Nortel - Nortel-specific functions

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

=item model model

=back
