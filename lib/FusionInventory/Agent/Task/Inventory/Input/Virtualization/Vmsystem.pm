package FusionInventory::Agent::Task::Inventory::Input::Virtualization::Vmsystem;

# Contains code from imvirt:
# URL: http://micky.ibh.net/~liske/imvirt.html
# Authors:  Thomas Liske <liske@ibh.de>
# Copyright: 2008 IBH IT-Service GmbH [http://www.ibh.de/]
# License: GPLv2+


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

my @vmware_patterns = (
    'VMware vmxnet virtual NIC driver',
    'Vendor: VMware\s+Model: Virtual disk',
    'Vendor: VMware,\s+Model: VMware Virtual ',
    ': VMware Virtual IDE CDROM Drive'
);
my $vmware_pattern = _assemblePatterns(@vmware_patterns);

my @qemu_patterns = (
    ' QEMUAPIC ',
    'QEMU Virtual CPU',
    ': QEMU HARDDISK,',
    ': QEMU CD-ROM,'
);
my $qemu_pattern = _assemblePatterns(@qemu_patterns);

my @virtual_machine_patterns = (
    ': Virtual HD,',
    ': Virtual CD,'
);
my $virtual_machine_pattern = _assemblePatterns(@virtual_machine_patterns);

my @virtualbox_patterns = (
    ' VBOXBIOS ',
    ': VBOX HARDDISK,',
    ': VBOX CD-ROM,',
);
my $virtualbox_pattern = _assemblePatterns(@virtualbox_patterns);

my @xen_patterns = (
    'Hypervisor signature: xen',
    'Xen virtual console successfully installed',
    'Xen reported:',
    'Xen: \d+ - \d+',
    'xen-vbd: registered block device',
    'ACPI: [A-Z]{4} \(v\d+\s+Xen ',
);
my $xen_pattern = _assemblePatterns(@xen_patterns);

my %module_patterns = (
    '^vmxnet\s' => 'VMware',
    '^xen_\w+front\s' => 'Xen',
);

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # return immediatly if vm type has already been found
    return if $inventory->{content}{HARDWARE}{VMSYSTEM} ne "Physical";

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


    my $uuid = 0;
    my $vmid = 0;

    if ( $status eq 'Virtuozzo' ) {
        if (-f '/proc/self/status') {
            my $handle = getFileHandle(
                file => '/proc/self/status',
                logger => $logger
            );
            while (my $line = <$handle>) {
                my ( $varID, $varValue ) = split( ":", $line );
                $vmid = $varValue if ( $varID eq 'envID' && $varValue > 0 );
            }
        }
    }

    my $h;

    $h -> { VMSYSTEM } = $status;
    $h -> { UUID } = $uuid if $uuid;
    $h -> { VMID } = $vmid if $vmid;

    $inventory->setHardware($h);

}

sub _getStatus {
    my ($logger) = @_;

    # Solaris zones
    if (canRun('/usr/sbin/zoneadm')) {
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

    my $result;

    # loaded modules

    if (-f '/proc/modules') {
        my $handle = getFileHandle(
            file => '/proc/modules',
            logger => $logger
        );
        while (my $line = <$handle>) {
            foreach my $pattern (keys %module_patterns) {
                next unless $line =~ /$pattern/;
                $result = $module_patterns{$pattern};
                last;
            }
        }
        close $handle;
    }
    return $result if $result;

    # dmesg

    if (-r '/var/log/dmesg') {
        my $handle = getFileHandle(file => '/var/log/dmesg', logger => $logger);
        $result = _matchPatterns($handle);
        close $handle;
    } elsif (-x '/bin/dmesg') {
        my $handle = getFileHandle(command => '/bin/dmesg', logger => $logger);
        $result = _matchPatterns($handle);
        close $handle;
    } elsif (-x '/sbin/dmesg') {
        # On OpenBSD, dmesg is in sbin
        # http://forge.fusioninventory.org/issues/402
        my $handle = getFileHandle(command => '/sbin/dmesg', logger => $logger);
        $result = _matchPatterns($handle);
        close $handle;
    }
    return $result if $result;

    # scsci

    if (-f '/proc/scsi/scsi') {
        my $handle = getFileHandle(
            file => '/proc/scsi/scsi',
            logger => $logger
        );
        $result = _matchPatterns($handle);
        close $handle;
    }
    return $result if $result;

    # OpenVZ
    if (-f '/proc/self/status') {
        my $handle = getFileHandle(
            file => '/proc/self/status',
            logger => $logger
        );
        while (my $line = <$handle>) {
            my ($key, $value) = split(/:/, $line);
            $result = "Virtuozzo" if $key eq 'envID' && $value > 0;
        }
    }
    return $result if $result;

    return 'Physical';
}

sub _assemblePatterns {
    my (@patterns) = @_;

    my $pattern = '(?:' . join('|', @patterns) . ')';
    return qr/$pattern/;
}

sub _matchPatterns {
    my ($handle) = @_;

    while (my $line = <$handle>) {
        return 'VMware'          if $line =~ $vmware_pattern;
        return 'QEMU'            if $line =~ $qemu_pattern;
        return 'Virtual Machine' if $line =~ $virtual_machine_pattern;
        return 'VirtualBox'      if $line =~ $virtualbox_pattern;
        return 'Xen'             if $line =~ $xen_pattern;
    }
}

1;
