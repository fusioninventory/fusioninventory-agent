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

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return unless can_run('ipmitool');
    return system('ipmitool lan print 2> /dev/null') == 0;
}

# Initialise the distro entry
sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $handle = getFileHandle(
        logger => $logger,
        command => "ipmitool lan print",
    );

    return unless $handle;

    my $ipaddress;
    my $ipgateway;
    my $ipmask;
    my $macaddr;

    while (my $line = <$handle>) {
        if ($line =~ /^IP Address\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipaddress = $1;
        }
        if ($line =~ /^Default Gateway IP\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipgateway = $1;
        }
        if ($line =~ /^Subnet Mask\s+:\s+(\d+\.\d+\.\d+\.\d+)/) {
            $ipmask = $1;
        }
        if ($line =~ /^MAC Address\s+:\s+([0-9a-f]{2}(:[0-9a-f]{2}){5})/) {
            $macaddr = $1;
        }
    }
    close $handle;

    my $ipsubnet = getSubnetAddress($ipaddress, $ipmask);

    $inventory->addNetwork({
        DESCRIPTION => 'bmc',
        IPADDRESS   => $ipaddress,
        IPGATEWAY   => $ipgateway,
        IPMASK      => $ipmask,
        IPSUBNET    => $ipsubnet,
        MACADDR     => $macaddr,
        STATUS      => $ipaddress != '0.0.0.0' ? "Up" : "Down",
        TYPE        => 'Ethernet'
    });
}

1;
