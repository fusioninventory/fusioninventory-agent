package FusionInventory::Agent::Tools::Linux;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;
use FusionInventory::Agent::Tools::Network;

our @EXPORT = qw(
    getDevicesFromUdev
    getDevicesFromHal
    getDevicesFromProc
    getCPUsFromProc
    getInfoFromSmartctl
    getInterfacesFromIfconfig
    getInterfacesFromIp
);

memoize('getDevicesFromUdev');

sub getDevicesFromUdev {
    my (%params) = @_;

    my @devices;

    foreach my $file (glob ("/dev/.udev/db/*")) {
        my $device = getFirstMatch(
            file    => $file,
            pattern => qr/^N:(\S+)/
        );
        next unless $device;
        next unless $device =~ /([hsv]d[a-z]|sr\d+)$/;
        push (@devices, _parseUdevEntry(
                logger => $params{logger}, file => $file, device => $device
            ));
    }

    foreach my $device (@devices) {
        next if $device->{TYPE} && $device->{TYPE} eq 'cd';
        $device->{DISKSIZE} = getDeviceCapacity(device => '/dev/' . $device->{NAME})
    }

    return @devices;
}

sub _parseUdevEntry {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

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

    $result->{NAME} = $params{device};

    return $result;
}

sub getCPUsFromProc {
    my (%params) = (
        file => '/proc/cpuinfo',
        @_
    );

    my $handle = getFileHandle(%params);

    my (@cpus, $cpu);

    while (my $line = <$handle>) {
        if ($line =~ /^([^:]+\S) \s* : \s (.+)/x) {
            $cpu->{lc($1)} = trimWhitespace($2);
        } elsif ($line =~ /^$/) {
            # an empty line marks the end of a cpu section
            # push to the list, but only if it is a valid cpu
            push @cpus, $cpu if $cpu && _isValidCPU($cpu);
            undef $cpu;
        }
    }
    close $handle;

    # push remaining cpu to the list, if it is valid cpu
    push @cpus, $cpu if $cpu && _isValidCPU($cpu);

    return @cpus;
}

sub _isValidCPU {
    my ($cpu) = @_;

    return exists $cpu->{processor} || exists $cpu->{cpu};
}


sub getDevicesFromHal {
    my (%params) = (
        command => '/usr/bin/lshal',
        @_
    );
    my $handle = getFileHandle(%params);

    my (@devices, $device);

    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ m{^udi = '/org/freedesktop/Hal/devices/(storage|legacy_floppy|block)}) {
            $device = {};
            next;
        }

        next unless defined $device;

        if ($line =~ /^$/) {
            push(@devices, $device);
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

    return @devices;
}

sub getDevicesFromProc {
    my (%params) = @_;

    my $logger = $params{logger};

    # compute list of devices
    my @names;

    foreach my $file (glob ("/sys/block/*")) {
        next unless $file =~ /([shv]d[a-z]|fd\d)$/;
        push @names, $1;
    }

    my $command = getFirstLine(command => '/sbin/fdisk -v') =~ '^GNU' ?
        "/sbin/fdisk -p -l" :
        "/sbin/fdisk -l"    ;

    my $handle = getFileHandle(
        command => $command,
        logger  => $logger
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ m{^/dev/([shv]d[a-z])};
        push @names, $1;
    }
    close $handle;

    # filter duplicates
    my %seen;
    @names = grep { !$seen{$_}++ } @names;

    # extract information
    my @devices;
    foreach my $name (@names) {
        my $device = {
            NAME         => $name,
            MANUFACTURER => _getValueFromSysProc($logger, $name, 'vendor'),
            MODEL        => _getValueFromSysProc($logger, $name, 'model'),
            FIRMWARE     => _getValueFromSysProc($logger, $name, 'rev'),
            SERIALNUMBER => _getValueFromSysProc($logger, $name, 'serial'),
            TYPE         =>
                _getValueFromSysProc($logger, $name, 'removable') ?
                    'removable' : 'disk'
        };
        push @devices, $device;
    }

    return @devices;
}

sub _getValueFromSysProc {
    my ($logger, $device, $key) = @_;

    ## no critic (ExplicitReturnUndef)

    my $file =
        -f "/sys/block/$device/device/$key" ? "/sys/block/$device/device/$key" :
        -f "/proc/ide/$device/$key"         ? "/proc/ide/$device/$key" :
                                              undef;

    return undef unless $file;

    my $handle = getFileHandle(file => $file, logger => $logger);
    return undef unless $handle;

    my $value = <$handle>;
    close $handle;

    chomp $value;
    $value =~ s/^(\w+)\W*/$1/;

    return $value;
}

sub getInfoFromSmartctl {
    my (%params) = @_;

    my $handle = getFileHandle(
        %params,
        command => $params{device} ? "smartctl -i $params{device}" : undef,
    );
    return unless $handle;

    my $info = {
        TYPE        => 'disk',
        DESCRIPTION => 'SATA',
    };

    while (my $line = <$handle>) {
        if ($line =~ /^Vendor: +(\S+)/i) {
            $info->{MANUFACTURER} = getCanonicalManufacturer($1);
            next;
        }

        if ($line =~ /^Product: +(\S+)/i) {
            $info->{MODEL} = $1;
            next;
        }

        if ($line =~ /^Revision: +(\S+)/i) {
            $info->{FIRMWARE} = $1;
            next;
        }

        if ($line =~ /^User Capacity: +(\S.+\S)/i) {
            $info->{DISKSIZE} = getCanonicalSize($1, 1024);
            next;
        }

        if ($line =~ /^Transport protocol: +(\S+)/i) {
            $info->{DESCRIPTION} = $1;
            next;
        }

        if ($line =~ /^Device type: +(\S+)/i) {
            $info->{TYPE} = $1;
            next;
        }

        if ($line =~ /^Serial number: +(\S+)/i) {
            $info->{SERIALNUMBER} = $1;
            next;
        }
    }
    close $handle;

    return $info;
}

sub getInterfacesFromIfconfig {
    my (%params) = (
        command => '/sbin/ifconfig -a',
        @_
    );
    my $handle = getFileHandle(%params);
    return unless $handle;

    my @interfaces;
    my $interface;

    my %types = (
        Ethernet => 'ethernet',
    );

    while (my $line = <$handle>) {
        if ($line =~ /^$/) {
            # end of interface section
            push @interfaces, $interface if $interface;
            next;
        }

        if ($line =~ /^([\w\d.]+)/) {
            # new interface

            $interface = {
                STATUS      => 'Down',
                DESCRIPTION => $1
            }

        }
        if ($line =~ /
            inet \s ($ip_address_pattern) \s+
            netmask \s ($ip_address_pattern) \s+
            broadcast \s $ip_address_pattern
        /x) {
            $interface->{IPADDRESS} = $1;
            $interface->{IPMASK} = $2;
        }

        if ($line =~ /
            ether \s ($mac_address_pattern)
            .+
            \( Ethernet \)
        /x) {
            $interface->{MACADDR} = $1;
            $interface->{TYPE} = 'ethernet';
        }

        if ($line =~ /inet6 \s (\S+)/x) {
            $interface->{IPADDRESS6} = $1;
        }

        if ($line =~ /inet addr:($ip_address_pattern)/i) {
            $interface->{IPADDRESS} = $1;
        }

        if ($line =~ /Mask:($ip_address_pattern)/) {
            $interface->{IPMASK} = $1;
        }

        if ($line =~ /inet6 addr: (\S+)/i) {
            $interface->{IPADDRESS6} = $1;
        }

        if ($line =~ /hwadd?r\s+($mac_address_pattern)/i) {
            $interface->{MACADDR} = $1;
        }

        if ($line =~ /^\s+UP\s/) {
            $interface->{STATUS} = 'Up';
        }

        if ($line =~ /flags=.*[<,]UP[>,]/) {
            $interface->{STATUS} = 'Up';
        }

        if ($line =~ /Link encap:(\S+)/) {
            $interface->{TYPE} = $types{$1};
        }

    }
    close $handle;

    return @interfaces;
}
sub getInterfacesFromIp {
    my (%params) = (
        command => '/sbin/ip addr show',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @interfaces;
    my $interface;

    while (my $line = <$handle>) {
        if ($line =~ /^\d+:\s+(\S+): <([^>]+)>(.*)/) {

            $interface = {
                DESCRIPTION => $1
            };

            my $flags = $2;
            my $remaining = $3;

            if ($remaining =~ /state DOWN /) {
                $interface->{STATUS} = 'Down';
            } else {
                foreach my $flag (split(/,/, $flags)) {
                    next unless $flag eq 'UP' || $flag eq 'DOWN';
                    $interface->{STATUS} = ucfirst(lc($flag));
                }
            }
        } elsif ($line =~ /link\/\S+ ($any_mac_address_pattern)?/) {
            $interface->{MACADDR} = $1;

            # if courrent interface is not up, there won't be any address lines
            push @interfaces, $interface
                unless $interface->{STATUS} && $interface->{STATUS} eq 'Up';
        } elsif ($line =~ /inet6 (\S+)\/(\d{1,2})/) {
            my $address = $1;
            my $mask    = getNetworkMaskIPv6($2);
            my $subnet  = getSubnetAddressIPv6($address, $mask);

            push @interfaces, {
                IPADDRESS6  => $address,
                IPMASK6     => $mask,
                IPSUBNET6   => $subnet,
                STATUS      => $interface->{STATUS},
                DESCRIPTION => $interface->{DESCRIPTION},
                MACADDR     => $interface->{MACADDR}
            };
        } elsif ($line =~ /inet ($ip_address_pattern)(?:\/(\d{1,3}))?/) {
            my $address = $1;
            my $mask    = getNetworkMask($2);
            my $subnet  = getSubnetAddress($address, $mask);

            push @interfaces, {
                IPADDRESS   => $address,
                IPMASK      => $mask,
                IPSUBNET    => $subnet,
                STATUS      => $interface->{STATUS},
                DESCRIPTION => $interface->{DESCRIPTION},
                MACADDR     => $interface->{MACADDR}
            };
        }
    }

    return @interfaces;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Linux - Linux generic functions

=head1 DESCRIPTION

This module provides some generic functions for Linux.

=head1 FUNCTIONS

=head2 getDevicesFromUdev(%params)

Returns a list of devices, by parsing /dev/.udev directory.
This directory is not exported anymore with recent udev.

Availables parameters:

=over

=item logger a logger object

=back

=head2 getDevicesFromHal(%params)

Returns a list of devices, by parsing lshal output.

Availables parameters:

=over

=item logger a logger object

=item command the exact command to use (default: /usr/sbin/lshal)

=item file the file to use, as an alternative to the command

=back

=head2 getDevicesFromProc(%params)

Returns a list of devices, by parsing /proc filesystem.

Availables parameters:

=over

=item logger a logger object

=back

=head2 getCPUsFromProc(%params)

Returns a list of cpus, by parsing /proc/cpuinfo file

Availables parameters:

=over

=item logger a logger object

=item file the file to use (default: /proc/cpuinfo)

=back

=head2 getInfoFromSmartctl(%params)

Returns some information about a drive, using smartctl.

Availables parameters:

=over

=item logger a logger object

=item device the device to use

=item file the file to use

=back

=head2 getInterfacesFromIfconfig(%params)

Returns the list of interfaces, by parsing ifconfig command output.

Availables parameters:

=over

=item logger a logger object

=item command the command to use (default: /sbin/ifconfig -a)

=item file the file to use

=back

=head2 getInterfacesFromIp(%params)

Returns the list of interfaces, by parsing ip command output.

Availables parameters:

=over

=item logger a logger object

=item command the command to use (default: /sbin/ip addr show)

=item file the file to use

=back
