package FusionInventory::Agent::Tools::Generic;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getDmidecodeInfos
    getCpusFromDmidecode
    getPCIDevices
    getPCIDeviceVendor
    getPCIDeviceClass
);

my %PCIVendors;
my %PCIClasses;

memoize('getDmidecodeInfos');
memoize('getPCIDevices');

sub getDmidecodeInfos {
    my (%params) = (
        command => 'dmidecode',
        @_
    );

    if ($OSNAME eq 'MSWin32') {
        # don't run dmidecode on Win2003
        # http://forge.fusioninventory.org/issues/379
        Win32->require();
        my @osver = Win32::GetOSVersion();
        return if
            $osver[4] == 2 &&
            $osver[1] == 5 &&
            $osver[2] == 2;
    }

    my $handle = getFileHandle(%params);
    my ($info, $block, $type);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            # start of block

            # push previous block in list
            if ($block) {
                push(@{$info->{$type}}, $block);
                undef $block;
            }

            # switch type
            $type = $1;

            next;
        }

        next unless defined $type;

        next unless $line =~ /^\s+ ([^:]+) : \s (.*\S)/x;

        next if
            $2 eq 'N/A'           ||
            $2 eq 'Not Specified' ||
            $2 eq '<BAD INDEX>'   ||
            $2 eq 'Not Present'   ;

        $block->{$1} = $2;
    }
    close $handle;

    # do not return anything if dmidecode output is obviously truncated
    return if keys %$info < 2;

    return $info;
}

sub getCpusFromDmidecode {
    my $infos = getDmidecodeInfos(@_);

    return unless $infos->{4};

    my @cpus;
    foreach my $info (@{$infos->{4}}) {
        next if $info->{Status} && $info->{Status} =~ /Unpopulated/i;

        my $proc_manufacturer = $info->{'Processor Manufacturer'};
        my $proc_version      = $info->{'Processor Version'};

        # VMware
        next if
            ($proc_manufacturer && $proc_manufacturer eq '000000000000') &&
            ($proc_version      && $proc_version eq '00000000000000000000000000000000');

        my $cpu = {
            SERIAL     => $info->{'Serial Number'},
            ID         => $info->{ID},
            CORE       => $info->{'Core Count'} || $info->{'Core Enabled'},
            THREAD     => $info->{'Thread Count'},
            FAMILYNAME => $info->{'Family'}
        };
        $cpu->{MANUFACTURER} = $info->{'Manufacturer'} || $info->{'Processor Manufacturer'};
        $cpu->{NAME} =
            ($cpu->{MANUFACTURER} =~ /Intel/ ? $info->{'Family'} : undef) ||
            $info->{'Version'}                                     ||
            $info->{'Processor Family'}                            ||
            $info->{'Processor Version'};

       if ($cpu->{ID}) {

            # Split CPUID to get access to its content
            my @id = split ("",$cpu->{ID});
            # convert hexadecimal value
            $cpu->{STEPPING} = hex $id[1];
            # family number is composed of 3 hexadecimal number
            $cpu->{FAMILYNUMBER} = hex $id[9] . $id[10] . $id[4];
            $cpu->{MODEL} = hex $id[7] . $id[0];
        }

        if ($info->{Version}) {
            if ($info->{Version} =~ /([\d\.]+)MHz$/) {
                $cpu->{SPEED} = $1;
            } elsif ($info->{Version} =~ /([\d\.]+)GHz$/) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }
        if (!$cpu->{SPEED} && $info->{'Max Speed'}) {
            # We only look for 3 digit Mhz frequency to avoid abvious bad
            # value like 30000 (#633)
            if ($info->{'Max Speed'} =~ /^\s*(\d{3,4})\s*Mhz/i) {
                $cpu->{SPEED} = $1;
            } elsif ($info->{'Max Speed'} =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }
        if (!$cpu->{SPEED} && $info->{'Current Speed'}) {
            if ($info->{'Current Speed'} =~ /^\s*(\d{3,4})\s*Mhz/i) {
                $cpu->{SPEED} = $1;
            } elsif ($info->{'Current Speed'} =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }

        if ($info->{'External Clock'}) {
            if ($info->{'External Clock'} =~ /^\s*(\d+)\s*Mhz/i) {
                $cpu->{EXTERNAL_CLOCK} = $1;
            } elsif ($info->{'External Clock'} =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{EXTERNAL_CLOCK} = $1 * 1000;
            }
        }

        push @cpus, $cpu;
    }

    return @cpus;
}

sub getPCIDevices {
    my (%params) = (
        command => 'lspci -v -nn',
        @_
    );
    my $handle = getFileHandle(%params);

    my (@controllers, $controller);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /^
            (\S+) \s                     # slot
            ([^[]+) \s                   # name
            \[([a-f\d]+)\]: \s           # class
            ([^[]+) \s                   # manufacturer
            \[([a-f\d]+:[a-f\d]+)\]      # id
            (?:\s \(rev \s (\d+)\))?     # optional version
            /x) {

            $controller = {
                PCISLOT      => $1,
                NAME         => $2,
                PCICLASS     => $3,
                MANUFACTURER => $4,
                PCIID        => $5,
                REV          => $6
            };
            next;
        }

        next unless defined $controller;

        if ($line =~ /^$/) {
            push(@controllers, $controller);
            undef $controller;
        } elsif ($line =~ /^\tKernel driver in use: (\w+)/) {
            $controller->{DRIVER} = $1;
        } elsif ($line =~ /^\tSubsystem: ([a-f\d]{4}:[a-f\d]{4})/) {
            $controller->{PCISUBSYSTEMID} = $1;
        }
    }

    close $handle;

    return @controllers;
}

sub getPCIDeviceVendor {
    my (%params) = @_;

    _loadPCIDatabase(%params) if !%PCIVendors;

    return unless $params{id};
    return $PCIVendors{$params{id}};
}

sub getPCIDeviceClass {
    my (%params) = @_;

    _loadPCIDatabase(%params) if !%PCIClasses;

    return unless $params{id};
    return $PCIClasses{$params{id}};
}

sub _loadPCIDatabase {
    my (%params) = @_;

    my $handle = getFileHandle(
        file   => "$params{datadir}/pci.ids",
        logger => $params{logger}
    );
    return unless $handle;

    my ($vendor_id, $device_id, $class_id);
    while (my $line = <$handle>) {

        if ($line =~ /^\t (\S{4}) \s+ (.*)/x) {
            # Device ID
            $device_id = $1;
            $PCIVendors{$vendor_id}->{devices}->{$device_id}->{name} = $2;
        } elsif ($line =~ /^\t\t (\S{4}) \s+ (\S{4}) \s+ (.*)/x) {
            # Subdevice ID
            my $subdevice_id = "$1:$2";
            $PCIVendors{$vendor_id}->{devices}->{$device_id}->{subdevices}->{$subdevice_id}->{name} = $3;
        } elsif ($line =~ /^(\S{4}) \s+ (.*)/x) {
            # Vendor ID
            $vendor_id = $1;
            $PCIVendors{$vendor_id}->{name} = $2;
        } elsif ($line =~ /^C \s+ (\S{2}) \s+ (.*)/x) {
            # Class ID
            $class_id = $1;
            $PCIClasses{$class_id}->{name} = $2;
        } elsif ($line =~ /^\t (\S{2}) \s+ (.*)/x) {
            # SubClass ID
            my $subclass_id = $1;
            $PCIClasses{$class_id}->{subclasses}->{$subclass_id}->{name} = $2;
        }
    }
    close $handle;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Generic - OS-independant generic functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions.

=head1 FUNCTIONS

=head2 getDmidecodeInfos

Returns a structured view of dmidecode output. Each information block is turned
into an hashref, block with same DMI type are grouped into a list, and each
list is indexed by its DMI type into the resulting hashref.

$info = {
    0 => [
        { block }
    ],
    1 => [
        { block },
        { block },
    ],
    ...
}

=head2 getCpusFromDmidecode()

Returns a list of CPUs, from dmidecode output.

=head2 getPCIDevices(%params)

Returns a list of PCI devices as a list of hashref, by parsing lspci command
output.

=over

=item logger a logger object

=item command the exact command to use (default: lspci -vvv -nn)

=item file the file to use, as an alternative to the command

=back

=head2 getPCIDeviceVendor(%params)

Returns the vendor matching this ID.

=over

=item id the vendor id

=item logger a logger object

=item datadir the directory holding the PCI database

=back

=head2 getPCIDeviceClass(%params)

Returns the class matching this ID.

=over

=item id the class id

=item logger a logger object

=item datadir the directory holding the PCI database

=back
