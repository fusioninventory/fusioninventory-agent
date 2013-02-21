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
package FusionInventory::Agent::Task::Inventory::Input::Generic::Ipmi;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    return unless canRun('ipmitool');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

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
        if ($line =~ /^IP Address\s+:\s+($ip_address_pattern)/) {
            $ipaddress = $1;
        }
        if ($line =~ /^Default Gateway IP\s+:\s+($ip_address_pattern)/) {
            $ipgateway = $1;
        }
        if ($line =~ /^Subnet Mask\s+:\s+($ip_address_pattern)/) {
            $ipmask = $1;
        }
        if ($line =~ /^MAC Address\s+:\s+($mac_address_pattern)/) {
            $macaddr = $1;
        }
    }
    close $handle;

    return unless $ipaddress && $ipmask;

    my $ipsubnet = getSubnetAddress($ipaddress, $ipmask);

    my $status = "Down";
    if ($ipaddress && ($ipaddress ne '0.0.0.0')) {
        $status = "Up";
    }

    $inventory->addEntry(
        section => 'NETWORKS',
        entry   => {
            DESCRIPTION => 'bmc',
            IPADDRESS   => $ipaddress,
            IPGATEWAY   => $ipgateway,
            IPMASK      => $ipmask,
            IPSUBNET    => $ipsubnet,
            MACADDR     => $macaddr,
            STATUS      => $status,
            TYPE        => 'Ethernet'
        }
    );
}

1;
