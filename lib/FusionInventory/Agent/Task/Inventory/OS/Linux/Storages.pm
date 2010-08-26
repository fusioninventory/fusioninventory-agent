package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return 1;
}

sub getDescription {
    my ($name, $manufacturer, $description, $serialnumber) = @_;

    # detected as USB by udev
    # TODO maybe we should trust udev detection by default?
    return "USB" if (defined ($description) && $description =~ /usb/i);

    if ($name =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
        if (($manufacturer && ($manufacturer =~ /ATA/)) || ($serialnumber && ($serialnumber =~ /ATA/))) {
            return  "SATA";
        } else {
            return "SCSI";
        }
    } else {
        return "IDE";
    }
}

# some hdparm release generated kernel error if they are
# run on CDROM device
# http://forums.ocsinventory-ng.org/viewtopic.php?pid=20810
sub correctHdparmAvailable {
    return unless can_run("hdparm");

    my $version = `hdparm -V`;
    my ($major, $minor) = $version =~ /^hdparm v(\d+)\.(\d+)/;

    # we need at least version 9.15
    return compareVersion($major, $minor, 9, 15);

}


sub doInventory {
    my ($params) = @_;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $devices;

    # get informations from hal first, if available
    if (can_run ("lshal")) {
        $devices = getDevicesFromHal($logger);
    }

    # index devices by name for comparaison
    my %devices = map { $_->{NAME} => $_ } @$devices;

    # complete with udev for missing bits
    foreach my $device (@{getDevicesFromUdev($logger)}) {
        my $name = $device->{NAME};
        foreach my $key (keys %$device) {
            $devices{$name}->{$key} = $device->{$key}
                if !$devices{$name}->{$key};
        }
    }

    # fallback on sysfs if udev didn't worked
    if (!$devices) {
        $devices = getDevicesFromProc($logger);
    }

    # get serial & firmware numbers from hdparm, if available
    if (correctHdparmAvailable()) {
        foreach my $device (@$devices) {
            if (!$device->{SERIALNUMBER} || !$device->{FIRMWARE}) {
                my $command = "hdparm -I /dev/$device->{NAME} 2>/dev/null";
                my $handle;
                if (!open $handle, '-|', $command) {
                    warn "Can't run $command: $ERRNO";
                } else {
                    while (my $line = <$handle>) {
                        if ($line =~ /^\s+Serial Number\s*:\s*(.+)/i) {
                            my $value = $1;
                            $value =~ s/\s+$//;
                            $device->{SERIALNUMBER} = $value
                                if !$device->{SERIALNUMBER};
                            next;
                        }
                        if ($line =~ /^\s+Firmware Revision\s*:\s*(.+)/i) {
                            my $value = $1;
                            $value =~ s/\s+$//;
                            $device->{FIRMWARE} = $value
                                if !$device->{FIRMWARE};
                            next;
                        }
                    }
                }
                close $handle;
            }
        }
    }

    foreach my $device (@$devices) {
        $device->{DESCRIPTION} = getDescription(
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

        if ($device->{DISKSIZE} && $device->{TYPE} =~ /^cd/) {
            $device->{DISKSIZE} = getDeviceCapacity($device->{NAME});
        }

        $inventory->addStorage($device);
    }
}

1;
