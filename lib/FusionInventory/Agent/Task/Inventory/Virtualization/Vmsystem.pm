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

sub isInventoryEnabled { 
  if ( can_run("zoneadm")){ # Is a solaris zone system capable ?
      return 1; 
  }
  if ( can_run ("dmidecode") ) { # 2.6 and under haven't -t parameter   
    if ( `dmidecode -V 2>/dev/null` >= 2.7 ) {
      return 1;
    }
  } 
  return 0;
} 

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $dmidecode = '/usr/sbin/dmidecode';
    my $cmd = '$dmidecode -t system';

    my $dmesg = '/bin/dmesg | head -n 750';

    my $status = "Physical";
    my $found = 0;
    # Solaris zones
    my @solaris_zones;
    @solaris_zones = `/usr/sbin/zoneadm list`;
    @solaris_zones = grep (!/global/,@solaris_zones);
    if(@solaris_zones){
        $status = "SolarisZone";
        $found = 1;
    }
 
    # paravirtualized oldstyle Xen - very simple ;)
    if(-d '/proc/xen') {
        $status = "Xen";
        $found = 1 ;
    }

    # newstyle Xen
    if($found == 0 and -r '/sys/devices/system/clocksource/clocksource0/available_clocksource') {
        if(`cat /sys/devices/system/clocksource/clocksource0/available_clocksource` =~ /xen/) {
          $status = "Xen";
          $found = 1 ;
        }
    }

    # dmidecode needs root to work :(
    if ($found == 0 and -r '/dev/mem' && -x $dmidecode) {
        my $sysprod = `$dmidecode -s system-product-name`;
        if ($sysprod =~ /^VMware/) {
          $status = "VMware";
          $found = 1;
        } elsif ($sysprod =~ /^Virtual Machine/) {
          $status = "Virtual Machine";
          $found = 1;
        } else {
          my $biosvend = `$dmidecode -s bios-vendor`;
          if ($biosvend =~ /^QEMU/) {
            $status = "QEMU";
            $found = 1;
          } elsif ($biosvend =~ /^Xen/) { # virtualized Xen
            $status = "Xen";
            $found = 1;
          }
        }
    }

    # Parse loaded modules
    my %modmap = (
        '^vmxnet\s' => 'VMware',
        '^xen_\w+front\s' => 'Xen',
    );

    if ($found == 0 and open(HMODS, '/proc/modules')) {
        while(<HMODS>) {
          foreach my $str (keys %modmap) {
            if (/$str/) {
              $status = "$modmap{$str}";
              $found = 1;
              last;
            }
          }
        }
        close(HMODS);
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

    if ($found == 0 and open(HDMSG, '/var/log/dmesg')) {
        while(<HDMSG>) {
          foreach my $str (keys %msgmap) {
            if (/$str/) {
              $status = "$msgmap{$str}";
              $found = 1;
              last;
            }
          }
        }
        close(HDMSG);
    }

    # Read kernel ringbuffer directly
    if ($found == 0 and open(HDMSG, '$dmesg |')) {
        while(<HDMSG>) {
          foreach my $str (keys %msgmap) {
            if (/$str/) {
              $status = "$msgmap{$str}";
              $found = 1;
              last;
            }
          }
        }
        close(HDMSG);
    }

    if ($found == 0 and open(HSCSI, '/proc/scsi/scsi')) {
        while(<HSCSI>) {
          foreach my $str (keys %msgmap) {
            if (/$str/) {
              $status = "$msgmap{$str}";
              $found = 1;
              last;
            }
          }
        }
        close(HSCSI);
    }

    $inventory->setHardware ({
      VMSYSTEM => $status,
      });
}

1;
