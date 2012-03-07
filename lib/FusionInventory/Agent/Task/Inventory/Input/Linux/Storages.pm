package FusionInventory::Agent::Task::Inventory::Input::Linux::Storages;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @devices;

    # get informations from hal first, if available
    if (canRun('lshal')) {
        @devices = getDevicesFromHal(logger => $logger);
    }

    # index devices by name for comparaison
    my %devices = map { $_->{NAME} => $_ } @devices;

    # complete with udev for missing bits
    foreach my $device (getDevicesFromUdev(logger => $logger)) {
        my $name = $device->{NAME};
        foreach my $key (keys %$device) {
            $devices{$name}->{$key} = $device->{$key}
                if !$devices{$name}->{$key};
        }
    }

    # fallback on sysfs if udev didn't worked
    if (!@devices) {
        @devices = getDevicesFromProc(logger => $logger);
    }

    # get serial & firmware numbers from hdparm, if available
    if (_correctHdparmAvailable()) {
        foreach my $device (@devices) {
            if (!$device->{SERIALNUMBER} || !$device->{FIRMWARE}) {
                my $handle = getFileHandle(
                    command => "hdparm -I /dev/$device->{NAME}",
                    logger  => $logger
                );
                next unless $handle;
                while (my $line = <$handle>) {
                    if ($line =~ /^\s+Serial Number\s*:\s*(.+)/i) {
                        my $value = $1;
                        $value =~ s/\s+$//;
                        $device->{SERIALNUMBER} = $value
                            if !$device->{SERIALNUMBER};
                        next;
                    } elsif ($line =~ /^\s+Firmware Revision\s*:\s*(.+)/i) {
                        my $value = $1;
                        $value =~ s/\s+$//;
                        $device->{FIRMWARE} = $value
                            if !$device->{FIRMWARE};
                        next;
                    } elsif ($line =~ /^\s*Transport:.*(SCSI|SATA|USB)/) {
                        $device->{DESCRIPTION} = $1;
                    } elsif ($line =~ /^\s*Model Number:\s*(.*?)\s*$/) {
                        $device->{MODEL} = $1;
                    } elsif ($line =~ /Logical Unit WWN Device Identifier:\s*(.*?)\s*$/) {
			$device->{WWN} = $1;
		    }
                }
                close $handle;
            }
        }
    }

    foreach my $device (@devices) {
        if (!$device->{DESCRIPTION}) {
            $device->{DESCRIPTION} = _getDescription(
                $device->{NAME},
                $device->{MANUFACTURER},
                $device->{DESCRIPTION},
                $device->{SERIALNUMBER}
            );
        }

        if (!$device->{MANUFACTURER} or $device->{MANUFACTURER} eq 'ATA') {
            $device->{MANUFACTURER} = getCanonicalManufacturer(
                $device->{MODEL}
            );
        }

        if ($device->{DISKSIZE} && $device->{TYPE} =~ /^cd/) {
            $device->{DISKSIZE} = getDeviceCapacity(device => '/dev/' . $device->{NAME});
        }

        $inventory->addEntry(section => 'STORAGES', entry => $device);
    }
}

sub _getDescription {
    my ($name, $manufacturer, $description, $serialnumber) = @_;

    # detected as USB by udev
    # TODO maybe we should trust udev detection by default?
    return "USB" if ($description && $description =~ /usb/i);

    if ($name =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
        if (
            ($manufacturer && $manufacturer =~ /ATA/) ||
            ($serialnumber && $serialnumber =~ /ATA/) ||
            ($description && $description =~ /ATA/)
        ) {
            return  "SATA";
        } else {
            return "SCSI";
        }
    } elsif ($name =~ /^vd/) {
            return "Virtual";
    } else {
        return "IDE";
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
