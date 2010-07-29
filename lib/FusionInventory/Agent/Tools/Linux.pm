package FusionInventory::Agent::Tools::Linux;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

our @EXPORT = qw(
    getDevicesFromUdev
    getDevicesFromHal
    getDeviceCapacity
    getCPUsFromProc
);

memoize('getDevicesFromUdev');

sub getDevicesFromUdev {
    my ($logger) = @_;

    my @devices;

    foreach my $file (glob ("/dev/.udev/db/*")) {
        next unless $file =~ /([sh]d[a-z])$/;
        my $device = $1;
        push (@devices, parseUdevEntry($logger, $file, $device));
    }

    foreach my $device (@devices) {
        next if $device->{TYPE} eq 'cd';
        $device->{DISKSIZE} = getDeviceCapacity($device->{NAME})
    }

    return @devices;
}

sub parseUdevEntry {
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

    $result->{SERIALNUMBER} = $serial
        unless $result->{SERIALNUMBER} =~ /\S/;

    $result->{NAME} = $device;

    return $result;
}

sub getDeviceCapacity {
    my ($dev) = @_;
    my $command = `/sbin/fdisk -v` =~ '^GNU' ? 'fdisk -p -s' : 'fdisk -s';
    # requires permissions on /dev/$dev
    my $cap = `$command /dev/$dev 2>/dev/null`;
    chomp $cap;
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
            $cpu->{$1} = $2;
        } elsif ($line =~ /^$/) {
            next unless $cpu;
            push @$cpus, $cpu;
            undef $cpu;
        }
    }
    close $handle;

    push @$cpus, $cpu if $cpu;

    return $cpus;
}

sub getDevicesFromHal {
    my ($logger) = @_;

    my $devices = parseLshal('/usr/bin/lshal', '-|');
    return @$devices;
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
