package FusionInventory::Agent::Task::NetInventory::Manufacturer::Cisco;

use strict;
use warnings;

use FusionInventory::Agent::Task::NetInventory::Manufacturer;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::SNMP qw(getLastElement);

sub setConnectedDevicesMacAddresses {
    my (%params) = @_;

    # use generic code, with vlan-specific results
    FusionInventory::Agent::Task::NetInventory::Manufacturer::setConnectedDevicesMacAddresses(
        ports   => $params{ports},
        walks   => $params{walks},
        results => $params{results}->{VLAN}->{$params{vlan_id}}
    );
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer::Cisco - Cisco-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Cisco hardware.

=head1 FUNCTIONS

=head2 setConnectedDevicesMacAddresses(%params)

Set mac addresses of connected devices.

=over

=item results raw values collected through SNMP

=item ports device ports list

=item walks model walk branch

=item vlan_id VLAN identifier

=back
