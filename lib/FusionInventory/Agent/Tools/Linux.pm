package FusionInventory::Agent::Tools::Linux;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

our @EXPORT = qw(
    getDevicesFromUdev
    getDevicesFromHal
    getDevicesFromProc
    getCPUsFromProc
);

memoize('getDevicesFromUdev');

sub getDevicesFromUdev {
    my ($logger) = @_;

    my $devices;

    foreach my $file (glob ("/dev/.udev/db/*")) {
        next unless $file =~ /([sh]d[a-z])$/;
        my $device = $1;
        push (@$devices, _parseUdevEntry($logger, $file, $device));
    }

    foreach my $device (@$devices) {
        next if $device->{TYPE} eq 'cd';
        $device->{DISKSIZE} = getDeviceCapacity($device->{NAME})
    }

    return $devices;
}

sub _parseUdevEntry {
    my ($logger, $file, $device) = @_;

    my $handle;
    if (!open $handle, '<', $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my ($result, $serial);
    while (my $line = <$handle>) {
        if ($line =~ /^S:.*-scsi-(\d+):(\d+):(\d+):(\d+)/) {
            $result->{SCSI_COID} = $1;
            $result->{SCSI_CHID} = $2;
            $result->{SCSI_UNID} = $3;
            $result->{SCSI_LUN} = $4;
        } elsif ($line =~ /^E:ID_VENDOR=(.*)/) {
            $result->{MANUFACTURER} = $1;
        } elsif ($line =~ /^E:ID_MODEL=(.*)/) {
            $result->{MODEL} = $1;
        } elsif ($line =~ /^E:ID_REVISION=(.*)/) {
            $result->{FIRMWARE} = $1;
        } elsif ($line =~ /^E:ID_SERIAL=(.*)/) {
            $serial = $1;
        } elsif ($line =~ /^E:ID_SERIAL_SHORT=(.*)/) {
            $result->{SERIALNUMBER} = $1;
        } elsif ($line =~ /^E:ID_TYPE=(.*)/) {
            $result->{TYPE} = $1;
        } elsif ($line =~ /^E:ID_BUS=(.*)/) {
            $result->{DESCRIPTION} = $1;
        }
    }
    close $handle;

    if (!$result->{SERIALNUMBER}) {
        $result->{SERIALNUMBER} = $serial;
    }

    $result->{NAME} = $device;

    return $result;
}

sub getDeviceCapacity {
    my ($dev) = @_;
    my $command = `/sbin/fdisk -v` =~ '^GNU' ? 'fdisk -p -s' : 'fdisk -s';
    # requires permissions on /dev/$dev
    my $cap;
    foreach (`$command /dev/$dev 2>/dev/null`) {
        next unless /^(\d+)/;
        $cap = $1;
    }
    $cap = int($cap / 1000) if $cap;
    return $cap;
}

sub getCPUsFromProc {
    my ($logger, $file) = @_;

    $file ||= '/proc/cpuinfo';

    my $handle;
    if (!open $handle, '<', $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my $cpus;

    my $cpu;
    while (my $line = <$handle>) {
        if ($line =~ /^([^:]+\S) \s* : \s (.+)/x) {
            $cpu->{lc($1)} = $2;
        } elsif ($line =~ /^$/) {
            # an empty line marks the end of a cpu section
            # push to the list, but only if it is a valid cpu
            push @$cpus, $cpu if $cpu &&
                    exists $cpu->{processor} ||
                    exists $cpu->{Processor} ||
                    exists $cpu->{cpu};
            undef $cpu;
        }
    }
    close $handle;

    # push remaining cpu to the list, if it is valid cpu
    push @$cpus, $cpu if $cpu &&
                    exists $cpu->{processor} ||
                    exists $cpu->{Processor} ||
                    exists $cpu->{cpu};

    return $cpus;
}

sub getDevicesFromHal {
    my ($logger, $file) = @_;

    return $file ?
        _parseLshal($logger, $file, '<')            :
        _parseLshal($logger, '/usr/bin/lshal', '-|');
}

sub _parseLshal {
    my ($logger, $file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        $logger->error("Can't open $file: $ERRNO");
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

sub getDevicesFromProc {
    my ($logger) = @_;

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
        $logger->error("Can't run $command: $ERRNO");
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
    my $devices;
    foreach my $name (@names) {
        my $device;
        $device->{NAME}         = $name;
        $device->{MANUFACTURER} = _getValueFromSysProc(
            $logger, $device, 'vendor'
        );
        $device->{MODEL}        = _getValueFromSysProc(
            $logger, $device, 'model'
        );
        $device->{FIRMWARE}     = _getValueFromSysProc(
            $logger, $device, 'rev'
        );
        $device->{SERIALNUMBER} = _getValueFromSysProc(
            $logger, $device, 'serial'
        );
        $device->{TYPE}         = _getValueFromSysProc(
            $logger, $device, 'removable'
        ) ?
            'removable' : 'disk';
        push (@$devices, $device);
    }

    return $devices;
}

sub _getValueFromSysProc {
    my ($logger, $device, $key) = @_;

    my $file =
        -f "/sys/block/$device/device/$key" ? "/sys/block/$device/device/$key" :
        -f "/proc/ide/$device/$key"         ? "/proc/ide/$device/$key" :
                                              undef;

    return unless $file;

    my $handle;
    if (!open $handle, '<', $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my $value = <$handle>;
    close $handle;

    chomp $value;
    $value =~ s/^(\w+)\W*/$1/;

    return $value;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Linux - Linux generic functions

=head1 DESCRIPTION

This module provides some generic functions for Linux.

=head1 FUNCTIONS

=head2 getDevicesFromUdev($logger)

Returns a list of devices as an arrayref of hashref, by parsing udev database.

=head2 getDevicesFromHal($logger)

Returns a list of devices as an arrayref of hashref, by parsing lshal output.

=head2 getDevicesFromProc($logger)

Returns a list of devices as an arrayref of hashref, by parsing /proc
filesystem.

=head2 getCPUsFromProc($logger)

Returns a list of cpus as an arrayref of hashref, by parsing /proc filesystem.

