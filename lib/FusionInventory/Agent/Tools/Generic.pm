package FusionInventory::Agent::Tools::Generic;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;
use Parse::DMIDecode;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getDMIDecodeParser
    getSanitizedValue
    getCpusFromDmidecode
    getPCIDevices
);

memoize('getDMIDecodeParser');
memoize('getPCIDevices');

sub getDMIDecodeParser {
    my (%params) = (
        command => 'dmidecode',
        @_
    );

    my $parser = Parse::DMIDecode->new(nowarnings => 1);

    local $RS = undef;
    my $handle = getFileHandle(%params);
    $parser->parse(<$handle>);
    close $handle;

    return $parser;
}

sub getSanitizedValue {
    my ($parser, $keyword) = @_;

    my $value = $parser->keyword($keyword);

    return $value if
        defined $value            &&
        $value ne 'Not Specified' &&
        $value ne 'Not Present'   &&
        $value ne 'N/A'           &&
        $value ne ''              ;

    return undef;
}

sub getCpusFromDmidecode {
    my $parser = getDMIDecodeParser(@_);

    my @cpus;
    foreach my $handle ($parser->get_handles(dmitype => 4)) {
        my $status = getSanitizedValue($handle, 'processor-status');
        next if $status && $status =~ /Unpopulated/i;

        my $proc_manufacturer =
            getSanitizedValue($handle, 'processor-processor-manufacturer');
        my $proc_version      =
            getSanitizedValue($handle, 'processor-processor-version');

        # VMware
        next if
            ($proc_manufacturer && $proc_manufacturer eq '000000000000') &&
            ($proc_version      && $proc_version eq '00000000000000000000000000000000');

        my $cpu = {
            SERIAL       => getSanitizedValue($handle, 'processor-serial-number'),
            ID           => getSanitizedValue($handle, 'processor-id'),
            CORE         => getSanitizedValue($handle, 'processor-core-count') ||
                            getSanitizedValue($handle, 'processor-core-enabled'),
            THREAD       => getSanitizedValue($handle, 'processor-thread-count'),
            FAMILYNAME   => getSanitizedValue($handle, 'processor-family'),
            MANUFACTURER => getSanitizedValue($handle, 'processor-manufacturer') ||
                            getSanitizedValue($handle, 'processor-processor-manufacturer')
        };

        $cpu->{NAME} =
            ($cpu->{MANUFACTURER} =~ /Intel/ ?
                getSanitizedValue($handle, 'processor-family') : undef ) ||
            getSanitizedValue($handle, 'processor-version')              ||
            getSanitizedValue($handle, 'processor-processor-family')     ||
            getSanitizedValue($handle, 'processor-processor-version');

       if ($cpu->{ID}) {
            # Split CPUID to get access to its content
            my @id = split ("",$cpu->{ID});
            # convert hexadecimal value
            $cpu->{STEPPING} = hex $id[1];
            # family number is composed of 3 hexadecimal number
            $cpu->{FAMILYNUMBER} = hex $id[9] . $id[10] . $id[4];
            $cpu->{MODEL} = hex $id[7] . $id[0];
        }

        my $version = getSanitizedValue($handle, 'processor-version');
        if ($version) {
            if ($version =~ /([\d\.]+)MHz$/) {
                $cpu->{SPEED} = $1;
            } elsif ($version =~ /([\d\.]+)GHz$/) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }

        my $max_speed = getSanitizedValue($handle, 'processor-max-speed');
        if (!$cpu->{SPEED} && $max_speed) {
            # We only look for 3 digit Mhz frequency to avoid abvious bad
            # value like 30000 (#633)
            if ($max_speed =~ /^\s*(\d{3,4})\s*Mhz/i) {
                $cpu->{SPEED} = $1;
            } elsif ($max_speed =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }

        my $current_speed = getSanitizedValue($handle, 'processor-current-speed');
        if (!$cpu->{SPEED} && $current_speed) {
            if ($current_speed =~ /^\s*(\d{3,4})\s*Mhz/i) {
                $cpu->{SPEED} = $1;
            } elsif ($current_speed =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }

        my $clock = getSanitizedValue($handle, 'processor-external-clock');
        if ($clock) {
            if ($clock =~ /^\s*(\d+)\s*Mhz/i) {
                $cpu->{EXTERNAL_CLOCK} = $1;
            } elsif ($clock =~ /^\s*(\d+)\s*Ghz/i) {
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
