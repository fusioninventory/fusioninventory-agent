package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

sub isInventoryEnabled {
    return 1;
}

sub getFromHal {

    my $devices = parseLshal('/usr/bin/lshal', '-|');
    return @$devices;
}

sub getFromSysProc {

    # compute list of devices
    my @names;

    foreach my $file (glob ("/sys/block/*")) {
        next unless $file =~ /([sh]d[a-z]|fd\d)$/;
        push(@names, $1);
    }

    my $command = `fdisk -v` =~ '^GNU' ?
        'fdisk -p -l 2>/dev/null' :
        'fdisk -l 2>/dev/null';
    if (!open my $handle, '-|', $command) {
        warn "Can't run $command: $ERRNO";
    } else {
        while (my $line = <$handle>) {
            next unless $line =~ (/^\/dev\/([sh]d[a-z])/);
            push(@names, $1);
        }
        close $handle;
    }

    # filter duplicates
    my %seen;
    @names = grep { !$seen{$_}++ } @names;

    # extract informations
    my @devices;
    foreach my $name (@names) {
        my $device;
        $device->{NAME}         = $name;
        $device->{MANUFACTURER} = getValueFromSysProc($device, 'vendor');
        $device->{MODEL}        = getValueFromSysProc($device, 'model');
        $device->{FIRMWARE}     = getValueFromSysProc($device, 'rev');
        $device->{SERIALNUMBER} = getValueFromSysProc($device, 'serial');
        $device->{TYPE}         = getValueFromSysProc($device, 'removable') ?
            'removable' : 'disk';
        push (@devices, $device);
    }

    return @devices;
}

sub getValueFromSysProc {
    my ($device, $key) = @_;

    my $file =
        -f "/sys/block/$device/device/$key" ? "/sys/block/$device/device/$key" :
        -f "/proc/ide/$device/$key"         ? "/proc/ide/$device/$key" :
                                              undef;

    return unless $file;

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $value = <$handle>;
    close $handle;

    chomp $value;
    $value =~ s/^(\w+)\W*/$1/;

    return $value;
}


sub getDescription {
    my ($name, $manufacturer, $description, $serialnumber) = @_;

    # detected as USB by udev
    # TODO maybe we should trust udev detection by default?
    return "USB" if (defined ($description) && $description =~ /usb/i);

    if ($name =~ /^s/) { # /dev/sd* are SCSI _OR_ SATA
        if ($manufacturer =~ /ATA/ || $serialnumber =~ /ATA/) {
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

    my @devices;

    # get informations from hal first, if available
    if (can_run ("lshal")) {
        @devices = getFromHal();
    }

    # index devices by name for comparaison
    my %devices = map { $_->{NAME} => $_ } @devices;

    # complete with udev for missing bits
    foreach my $device (getDevicesFromUdev()) {
        my $name = $device->{NAME};
        foreach my $key (keys %$device) {
            $devices{$name}->{$key} = $device->{$key}
                if !$devices{$name}->{$key};
        }
    }

    # fallback on sysfs if udev didn't worked
    if (!@devices) {
        @devices = getFromSysProc();
    }

    # get serial & firmware numbers from hdparm, if available
    if (correctHdparmAvailable()) {
        foreach my $device (@devices) {
            if (!$device->{SERIALNUMBER} || !$device->{FIRMWARE}) {
                my $command = "hdparm -I /dev/$device->{NAME} 2>/dev/null";
                if (!open my $handle, '-|', $command) {
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
                        if (/^\s+Firmware Revision\s*:\s*(.+)/i) { 
                            my $value = $1;
                            $value =~ s/\s+$//;
                            $device->{FIRMWARE} = $value
                                if !$device->{FIRMWARE};
                            next;
                        }
                    }
                    close $handle;
                }
            }
        }
    }

    foreach my $device (@devices) {
        $device->{DESCRIPTION} = getDescription(
            $device->{NAME},
            $device->{MANUFACTURER},
            $device->{DESCRIPTION},
            $device->{SERIALNUMBER}
        );

        if (!$device->{MANUFACTURER} or $device->{MANUFACTURER} eq 'ATA') {
            $device->{MANUFACTURER} = getManufacturer($device->{MODEL});
        }

        if ($device->{CAPACITY} && $device->{CAPACITY} =~ /^cd/) {
            $device->{CAPACITY} = getDeviceCapacity($device->{NAME});
        }

        $inventory->addStorage($device);
    }
}

sub parseLshal {
    my ($file, $mode) = @_;


    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($devices, $device);

    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ m{^udi = '/org/freedesktop/Hal/devices/(storage|legacy_floppy|block)}) {
            $device = {};
            next;
        }

        next unless defined $device;

        if ($line =~ /^$/) {
            push(@$devices, $device);
            undef $device;
        } elsif ($line =~ /^\s+ storage.serial \s = \s '([^']+)'/x) {
            $device->{SERIALNUMBER} = $1;
        } elsif ($line =~ /^\s+ storage.firmware_version \s = \s '([^']+)'/x) {
            $device->{FIRMWARE} = $1;
        } elsif ($line =~ /^\s+ block.device \s = \s '([^']+)'/x) {
            my $value = $1;
            ($device->{NAME}) = $value =~ m{/dev/(\S+)};
        } elsif ($line =~ /^\s+ info.vendor \s = \s '([^']+)'/x) {
            $device->{MANUFACTURER} = $1;
        } elsif ($line =~ /^\s+ storage.model \s = \s '([^']+)'/x) {
            $device->{MODEL} = $1;
        } elsif ($line =~ /^\s+ storage.drive_type \s = \s '([^']+)'/x) {
            $device->{TYPE} = $1;
        } elsif ($line =~ /^\s+ storage.size \s = \s (\S+)/x) {
            my $value = $1;
            $device->{DISKSIZE} = int($value/(1024*1024) + 0.5);
        }
    }
    close $handle;

    return $devices;
}

1;
