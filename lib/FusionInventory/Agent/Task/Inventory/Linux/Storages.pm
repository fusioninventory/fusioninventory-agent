package FusionInventory::Agent::Task::Inventory::Linux::Storages;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{storage};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $device (_getDevices(logger => $logger)) {
        $inventory->addEntry(section => 'STORAGES', entry => $device);
    }
}

sub _getDevices {
    my (%params) = @_;

    my $logger    = $params{logger};

    my @devices = _getDevicesBase(logger => $logger);

    # complete with udev for missing bits, if available
    if (-d '/dev/.udev/db/') {

        my %udev_devices = map { $_->{NAME} => $_ }
            getDevicesFromUdev(logger => $logger);

        foreach my $device (@devices) {
            # find corresponding udev entry
            my $udev_device = $udev_devices{$device->{NAME}};
            next unless $udev_device;

            foreach my $key (keys %$udev_device) {
                next if $device->{$key};
                $device->{$key} = $udev_device->{$key};
            }
        }
    }

    # get serial & firmware numbers from hdparm, if available
    if (_correctHdparmAvailable()) {
        foreach my $device (@devices) {
            next if $device->{SERIALNUMBER} && $device->{FIRMWARE};
            my $info = getHdparmInfo(
                device => "/dev/" . $device->{NAME},
                logger  => $logger
            );

            $device->{SERIALNUMBER} = $info->{serial}
                if $info->{serial} && !$device->{SERIALNUMBER};

            $device->{FIRMWARE} = $info->{firmware}
                if $info->{firmware} && !$device->{FIRMWARE};

            $device->{DESCRIPTION} = $info->{transport} if $info->{transport};
            $device->{MODEL}       = $info->{model} if $info->{model};
            $device->{WWN}         = $info->{wwn} if $info->{wwn};
        }
    }

    foreach my $device (@devices) {
        $device->{DESCRIPTION} = _fixDescription(
            $device->{NAME},
            $device->{MANUFACTURER},
            $device->{DESCRIPTION},
            $device->{SERIALNUMBER}
        );

        if (!$device->{MANUFACTURER} or $device->{MANUFACTURER} eq 'ATA') {
            $device->{MANUFACTURER} = getCanonicalManufacturer(
                $device->{MODEL}
            );
        }

        if (!$device->{DISKSIZE} && $device->{TYPE} !~ /^cd/) {
            $device->{DISKSIZE} = getDeviceCapacity(device => '/dev/' . $device->{NAME});
        }
    }

    return @devices;
}

sub _getDevicesBase {
    my (%params) = @_;

    my $logger = $params{logger};
    $logger->debug("retrieving devices list:");

    if (-d '/sys/block') {
        my @devices = getDevicesFromProc(logger => $logger);
        $logger->debug_result(
            action => 'reading /sys/block content',
            data   => scalar @devices
        );
        return @devices if @devices;
    } else {
        $logger->debug_result(
            action => 'reading /sys/block content',
            status => 'directory not available'
        );
    }

    if (canRun('/usr/bin/lshal')) {
        my @devices = getDevicesFromHal(logger => $logger);
        $logger->debug_result(
            action => 'running lshal command',
            data   => scalar @devices
        );
        return @devices if @devices;
    } else {
        $logger->debug_result(
            action => 'running lshal command',
            status => 'command not available'
        );
    }

    return;
}

sub _fixDescription {
    my ($name, $manufacturer, $description, $serialnumber) = @_;

    # detected as USB by udev
    # TODO maybe we should trust udev detection by default?
    return "USB" if ($description && $description =~ /usb/i);

    if ($name =~ /^sd/) { # /dev/sd* are SCSI _OR_ SATA
        if (
            ($manufacturer && $manufacturer =~ /ATA/) ||
            ($serialnumber && $serialnumber =~ /ATA/) ||
            ($description && $description =~ /ATA/)
        ) {
            return "SATA";
        } else {
            return "SCSI";
        }
    } elsif ($name =~ /^vd/  ||
            ($description && $description =~ /VIRTIO/)
        ) {
            return "Virtual";
    } else {
        return $description || "IDE";
    }
}

# some hdparm release generated kernel error if they are
# run on CDROM device
# http://forums.ocsinventory-ng.org/viewtopic.php?pid=20810
sub _correctHdparmAvailable {
    return unless canRun('hdparm');

    my ($major, $minor) = getFirstMatch(
        command => 'hdparm -V',
        pattern => qr/^hdparm v(\d+)\.(\d+)/
    );

    # we need at least version 9.15
    return compareVersion($major, $minor, 9, 15);

}

1;
