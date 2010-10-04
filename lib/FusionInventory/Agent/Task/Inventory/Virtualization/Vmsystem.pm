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

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    # return immediatly if vm type has already been found
    return if $inventory->{h}{CONTENT}{HARDWARE}{VMSYSTEM}->[0] ne "Physical";

    my $dmesg;
    # On OpenBSD, dmesg is in sbin
    # http://forge.fusioninventory.org/issues/402
    # TODO: we should remove the head call here
    foreach (qw(/bin/dmesg /sbin/dmesg)) {
        next unless -f;
        $dmesg = $_.' | head -n 750';
    }

    my $status;
    my $found = 0;

    # Solaris zones
    my @solaris_zones;
    @solaris_zones = `/usr/sbin/zoneadm list 2>/dev/null`;
    @solaris_zones = grep (!/global/,@solaris_zones);
    if(@solaris_zones){
        $status = "SolarisZone";
        $found = 1;
    }

    if (
        -d '/proc/xen' ||
        check_file_content(
            '/sys/devices/system/clocksource/clocksource0/available_clocksource',
            'xen'
        )
    ) {
        $found = 1 ;
        if (check_file_content('/proc/xen/capabilities', 'control_d')) {
            # dom0 host
        } else {
            # domU PV host
            $status = "Xen";
            # those information can't be extracted from dmidecode
            $inventory->setBios ({
                SMANUFACTURER => 'Xen',
                SMODEL => 'PVM domU'
            });
        }
    }

    # Parse loaded modules
    my %modmap = (
        '^vmxnet\s' => 'VMware',
        '^xen_\w+front\s' => 'Xen',
    );

    if ($found == 0) {
        if (open my $handle, '<', '/proc/modules') {
            while(<$handle>) {
                foreach my $str (keys %modmap) {
                    if (/$str/) {
                        $status = "$modmap{$str}";
                        $found = 1;
                        last;
                    }
                }
            }
            close $handle;
#        } else {
#            $logger->debug("Can't open /proc/modules: $ERRNO");
        }
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
        'ACPI: RSDP \(v\d+\s+Xen ' => 'Xen',
        'ACPI: XSDT \(v\d+\s+Xen ' => 'Xen',
        'ACPI: FADT \(v\d+\s+Xen ' => 'Xen',
        'ACPI: MADT \(v\d+\s+Xen ' => 'Xen',
        'ACPI: HPET \(v\d+\s+Xen ' => 'Xen',
        'ACPI: SSDT \(v\d+\s+Xen ' => 'Xen',
        'ACPI: DSDT \(v\d+\s+Xen ' => 'Xen',
    );

    if ($found == 0) {
        if (open my $handle, '<', '/var/log/dmesg') {
            while(<$handle>) {
                foreach my $str (keys %msgmap) {
                    if (/$str/) {
                        $status = "$msgmap{$str}";
                        $found = 1;
                        last;
                    }
                }
            }
            close($handle);
#        } else {
#            $logger->debug("Can't open /var/log/dmesg: $ERRNO");
        }
    }

    # Read kernel ringbuffer directly
    if ($found == 0 && $dmesg) {
        if (open my $handle, '-|', $dmesg) {
            while (<$handle>) {
                foreach my $str (keys %msgmap) {
                    if (/$str/) {
                        $status = "$msgmap{$str}";
                        $found = 1;
                        last;
                    }
                }
            }
            close $handle;
#        } else {
#            $logger->debug("Can't run $dmesg: $ERRNO");
        }
    }

    if ($found == 0) {
        if (open my $handle, '<', '/proc/scsi/scsi') {
            while (<$handle>) {
                foreach my $str (keys %msgmap) {
                    if (/$str/) {
                        $status = "$msgmap{$str}";
                        $found = 1;
                        last;
                    }
                }
            }
            close $handle;
#        } else {
#            $logger->debug("Can't open /proc/scsi/scsi: $ERRNO");
        }
    }

    if ($status) {
        $inventory->setHardware ({
                VMSYSTEM => $status,
            });
    }
}

sub check_file_content {
    my ($file, $pattern) = @_;

    return 0 unless -r $file;

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Can't open file $file: $ERRNO";
        return;
    }

    my $found = 0;

    while (my $line = <$handle>) {
        if ($line =~ /$pattern/) {
            $found = 1;
            last;
        }
    }
    close $handle;

    return $found;
}

1;
