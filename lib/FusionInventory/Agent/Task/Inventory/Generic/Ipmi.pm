#
# OcsInventory agent - IPMI lan channel report
#
# Copyright (c) 2008 Jean Parpaillon <jean.parpaillon@kerlabs.com>
#
# The Intelligent Platform Management Interface (IPMI) specification
# defines a set of common interfaces to a computer system which system
# administrators can use to monitor system health and manage the
# system. The IPMI consists of a main controller called the Baseboard
# Management Controller (BMC) and other satellite controllers.
#
# The BMC can be fetched through client like OpenIPMI drivers or
# through the network. Though, the BMC hold a proper MAC address.
#
# This module reports the MAC address and, if any, the IP
# configuration of the BMC. This is reported as a standard NIC.
#
package FusionInventory::Agent::Task::Inventory::Generic::Ipmi;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;

sub isEnabled {
    return unless canRun('ipmitool');
}

sub doInventory {}

1;
