package FusionInventory::Agent::Task::NetInventory::Manufacturer;

use strict;
use warnings;

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Manufacturer -
Manufacturer-specific methods

=head1 DESCRIPTION

This is the base class defining interface for all manufacturer-specific methods.

=head1 METHODS

=head2 setConnectedDevicesMacAddress($results, $ports, $walks, $vlan_id)

set mac addresses of connected devices.

=head2 setTrunkPorts($results, $ports)

set trunk bit on relevant ports.

=head2 setConnectedDevices($results, $ports, $walks)

set connected devices, through CDP or LLDP.
