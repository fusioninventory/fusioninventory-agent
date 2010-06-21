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
package FusionInventory::Agent::Task::Inventory::OS::Generic::Ipmi;

use strict;
use warnings;

sub isInventoryEnabled {
    return unless can_run("ipmitool");
    my @ipmitool = `ipmitool lan print 2> /dev/null`;
    return unless @ipmitool;
}

# Initialise the distro entry
sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $description;
    my $ipaddress;
    my $ipgateway;
    my $ipmask;
    my $ipsubnet;
    my $macaddr;
    my $status;
    my $type;

    foreach (`LANG=C ipmitool lan print 2> /dev/null`) {
        if (/^IP Address\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipaddress = $1;
        }
        if (/^Default Gateway IP\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipgateway = $1;
        }
        if (/^Subnet Mask\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipmask = $1;
        }
        if (/^MAC Address\s+:\s+([0-9a-f]{2}(:[0-9a-f]{2}){5})/) {
            $macaddr = $1;
        }
    }
    $description = 'bmc';
    my $binip = &ip_iptobin ($ipaddress, 4);
    my $binmask = &ip_iptobin ($ipmask, 4);
    my $binsubnet = $binip & $binmask;
    if (can_load("Net::IP qw(:PROC)")) {
        $ipsubnet = ip_bintoip($binsubnet, 4);
    }
    $status = 1 if $ipaddress != '0.0.0.0';
    $type = 'Ethernet';

    $inventory->addNetwork({
        DESCRIPTION => $description,
        IPADDRESS => $ipaddress,
        IPDHCP => "",
        IPGATEWAY => $ipgateway,
        IPMASK => $ipmask,
        IPSUBNET => $ipsubnet,
        MACADDR => $macaddr,
        STATUS => $status?"Up":"Down",
        TYPE => $type,
    });
}

1;
