package FusionInventory::Agent::Task::Inventory::Virtualization::Vmsystem;

# Initial FusionInventory::Agent::Task::Inventory::Virtualization::Vmsystem version: Nicolas EISEN
#
# Code include from imvirt - I'm virtualized?
#   http://micky.ibh.net/~liske/imvirt.html
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2008 (C) IBH IT-Service GmbH [http://www.ibh.de/]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#


##
#
# Outputs:
#   Xen
#   VirtualBox
#   Virtual Machine
#   VMware
#   QEMU
#   SolarisZone
#
# If no virtualization has been detected:
#   Physical
#
##

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # return immediatly if vm type has already been found
    return if $inventory->{h}{CONTENT}{HARDWARE}{VMSYSTEM} ne "Physical";

    my $status = _getStatus($logger);

    # for consistency with HVM domU
    if (
        $status eq 'Xen' &&
        !$inventory->{h}{CONTENT}{BIOS}{SMANUFACTURER}
    ) {
        $inventory->setBios({
            SMANUFACTURER => 'Xen',
            SMODEL => 'PVM domU'
        });
    }

    $inventory->setHardware({
        VMSYSTEM => $status,
    });

}

sub _getStatus {
    my ($logger) = @_;

    # Solaris zones
    if (can_run('/usr/sbin/zoneadm')) {
        my $zone = getZone();
        return 'SolarisZone' if $zone ne 'global';
    }

    # Xen PV host
    if (
        -d '/proc/xen' ||
        getFirstMatch(
            file    => '/sys/devices/system/clocksource/clocksource0/available_clocksource',
            pattern => qr/xen/
        )
    ) {
        if (getFirstMatch(
            file    => '/proc/xen/capabilities',
            pattern => qr/control_d/
        )) {
            # dom0 host
            return 'Physical';
        } else {
            # domU PV host
            return 'Xen';
        }
    }

    # Parse loaded modules
    my %modmap = (
        '^vmxnet\s' => 'VMware',
        '^xen_\w+front\s' => 'Xen',
    );

    if (-f '/proc/modules') {
        my $handle = getFileHandle(
            file => '/proc/modules',
            logger => $logger
        );
        while (<$handle>) {
            foreach my $str (keys %modmap) {
                next unless /$str/;
                close $handle;
                return $modmap{$str};
            }
        }
        close $handle;
    }

    # Let's parse some logs & /proc files for well known strings
    my %msgmap = (
        'VMware vmxnet virtual NIC driver' => 'VMware',
        'Vendor: VMware\s+Model: Virtual disk' => 'VMware',
        'Vendor: VMware,\s+Model: VMware Virtual ' => 'VMware',
        ': VMware Virtual IDE CDROM Drive' => 'VMware',

        ' QEMUAPIC ' => 'QEMU',
        'QEMU Virtual CPU' => 'QEMU',
        ': QEMU HARDDISK,' => 'QEMU',
        ': QEMU CD-ROM,' => 'QEMU',

        ': Virtual HD,' => 'Virtual Machine',
        ': Virtual CD,' => 'Virtual Machine',

        ' VBOXBIOS ' => 'VirtualBox',
        ': VBOX HARDDISK,' => 'VirtualBox',
        ': VBOX CD-ROM,' => 'VirtualBox',

        'Hypervisor signature: xen' => 'Xen',
        'Xen virtual console successfully installed' => 'Xen',
        'Xen reported:' => 'Xen',
        'Xen: \d+ - \d+' => 'Xen',
        'xen-vbd: registered block device' => 'Xen',
        'ACPI: [A-Z]{4} \(v\d+\s+Xen ' => 'Xen',
    );

    if (-f '/var/log/dmesg') {
        my $handle = getFileHandle(
            file => '/var/log/dmesg',
            logger => $logger
        );
        while (<$handle>) {
            foreach my $str (keys %msgmap) {
                next unless /$str/;
                close $handle;
                return $msgmap{$str};
            }
        }
        close $handle;
    }

    # On OpenBSD, dmesg is in sbin
    # http://forge.fusioninventory.org/issues/402
    # TODO: we should remove the head call here
    foreach my $dmesg (qw(/bin/dmesg /sbin/dmesg)) {
        next unless -f $dmesg;
        my $command = "$dmesg | head -n 750";

        my $handle = getFileHandle(
            command => $command,
            logger => $logger,
        );
        while (<$handle>) {
            foreach my $str (keys %msgmap) {
                next unless /$str/;
                close $handle;
                return $msgmap{$str};
            }
        }
        close $handle;
    }

    if (-f '/proc/scsi/scsi') {
        my $handle = getFileHandle(
            file => '/proc/scsi/scsi',
            logger => $logger
        );
        while (<$handle>) {
            foreach my $str (keys %msgmap) {
                next unless /$str/;
                close $handle;
                return $msgmap{$str};
            }
        }
        close $handle;
    }

    return 'Physical';
}

1;
