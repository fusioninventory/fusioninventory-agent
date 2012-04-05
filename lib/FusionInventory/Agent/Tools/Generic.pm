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
);

memoize('getDmidecodeInfos');
memoize('getPCIDevices');

sub getDmidecodeInfos {
    my (%params) = (
        command => 'dmidecode',
        @_
    );

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
            $2 eq 'Not Present'   ;

        $block->{$1} = $2;
    }
    close $handle;

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
            SERIAL => $info->{'Serial Number'},
            ID     => $info->{ID},
            CORE   => $info->{'Core Count'} || $info->{'Core Enabled'},
            THREAD => $info->{'Thread Count'},
        };
        $cpu->{MANUFACTURER} = $info->{'Manufacturer'} || $info->{'Processor Manufacturer'};
        $cpu->{NAME} =
            ($cpu->{MANUFACTURER} =~ /Intel/ ? $info->{'Family'} : undef) ||
            $info->{'Version'}                                     ||
            $info->{'Processor Family'}                            ||
            $info->{'Processor Version'};

        if ($info->{Version}) {
            if ($info->{Version} =~ /([\d\.]+)MHz$/) {
                $cpu->{SPEED} = $1;
            } elsif ($info->{Version} =~ /([\d\.]+)GHz$/) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }
        if (!$cpu->{SPEED}) {
            if ($info->{'Max Speed'}) {
                if ($info->{'Max Speed'} =~ /^\s*(\d+)\s*Mhz/i) {
                    $cpu->{SPEED} = $1;
                } elsif ($info->{'Max Speed'} =~ /^\s*(\d+)\s*Ghz/i) {
                    $cpu->{SPEED} = $1 * 1000;
                }
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
