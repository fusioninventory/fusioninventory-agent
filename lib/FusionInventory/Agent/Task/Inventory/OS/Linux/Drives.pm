package FusionInventory::Agent::Task::Inventory::OS::Linux::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 
        can_run('df') ||
        can_run('lshal');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # start with df command
    my @drives = grep {
# TODO: This list should be moved somewhere else like the one for Agent::Tools::Unix
        $_->{FILESYSTEM} !~ /^(tmpfs|usbfs|proc|devpts|devshm|udev)$/;
    } getFilesystemsFromDf(logger => $logger, string => getDfoutput());


    # get additional informations
    if (can_run('blkid')) {
        # use blkid if available, as it is filesystem-independant
        foreach my $drive (@drives) {
            my $line = getFirstLine(command => "blkid $drive->{VOLUMN}");
            $drive->{SERIAL} = $1 if $line =~ /\sUUID="(\S*)"\s/;
        }
    } else {
        # otherwise fallback to filesystem-dependant utilities
        my $has_dumpe2fs   = can_run('dumpe2fs');
        my $has_xfs_db     = can_run('xfs_db');
        my $has_dosfslabel = can_run('dosfslabel');
        my %months = (
            Jan => 1,
            Fev => 2,
            Mar => 3,
            Apr => 4,
            May => 5,
            Jun => 6,
            Jul => 7,
            Aug => 8,
            Sep => 9,
            Oct => 10,
            Nov => 11,
            Dec => 12,
        );

        foreach my $drive (@drives) {
            if ($drive->{FILESYSTEM} =~ /^ext(2|3|4|4dev)/ && $has_dumpe2fs) {
                my $handle = getFileHandle(
                    logger => $logger,
                    command => "dumpe2fs -h $drive->{VOLUMN}"
                );
                next unless $handle;
                while (my $line = <$handle>) {
                    if ($line =~ /Filesystem UUID:\s+(\S+)/) {
                        $drive->{SERIAL} = $1;
                    } elsif ($line =~ /Filesystem created:\s+\w+\s+(\w+)\s+(\d+)\s+([\d:]+)\s+(\d{4})$/) {
                        $drive->{CREATEDATE} = "$4/$months{$1}/$2 $3";
                    } elsif ($line =~ /Filesystem volume name:\s*(\S.*)/) {
                        $drive->{LABEL} = $1 unless $1 eq '<none>';
                    }
                }
                close $handle;
                next;
            }

            if ($drive->{FILESYSTEM} eq 'xfs' && $has_xfs_db) {
                ($drive->{SERIAL}) = getFirstMatch(
                    logger  => $logger,
                    command => "xfs_db -r -c uuid $drive->{VOLUMN}",
                    pattern => qr/^UUID =\s+(\S+)/
                );
                ($drive->{LABEL}) = getFirstMatch(
                    logger  => $logger,
                    command => "xfs_db -r -c label $drive->{VOLUMN}",
                    pattern => qr/^label =\s+"(\S+)"/
                );
                next;
            }

            if ($drive->{FILESYSTEM} eq 'vfat' && $has_dosfslabel) {
                $drive->{LABEL} = getFirstLine(
                    logger  => $logger,
                    command => "dosfslabel $drive->{VOLUMN}"
                );
                next;
            }
        }
    }

    # complete with hal if available
    if (can_run('lshal')) {
        my @hal_drives = _getDrivesFromHal();
        my %hal_drives = map { $_->{VOLUMN} => $_ } @hal_drives;

        foreach my $drive (@drives) {
            # retrieve hal informations for this drive
            my $hal_drive = $hal_drives{$drive->{VOLUMN}};
            next unless $hal_drive;

            # take hal information if it doesn't exist already
            foreach my $key (keys %$hal_drive) {
                $drive->{$key} = $hal_drive->{$key}
                    if !$drive->{$key};
            }
        }
    }

    foreach my $drive (@drives) {
        $inventory->addDrive($drive);
    }
}

sub _getDrivesFromHal {
    my $devices = _parseLshal(command => '/usr/bin/lshal');
    return @$devices;
}

sub _parseLshal {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $devices = [];
    my $device = {};

    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ m{^udi = '/org/freedesktop/Hal/devices/(volume|block).*}) {
            $device = {};
            next;
        }

        next unless defined $device;

        if ($line =~ /^$/) {
            if ($device->{ISVOLUME}) {
                delete($device->{ISVOLUME});
                push(@$devices, $device);
            }
            undef $device;
        } elsif ($line =~ /^\s+ block.device \s = \s '([^']+)'/x) {
            $device->{VOLUMN} = $1;
        } elsif ($line =~ /^\s+ volume.fstype \s = \s '([^']+)'/x) {
            $device->{FILESYSTEM} = $1;
        } elsif ($line =~ /^\s+ volume.label \s = \s '([^']+)'/x) {
            $device->{LABEL} = $1;
        } elsif ($line =~ /^\s+ volume.uuid \s = \s '([^']+)'/x) {
            $device->{SERIAL} = $1;
        } elsif ($line =~ /^\s+ storage.model \s = \s '([^']+)'/x) {
            $device->{TYPE} = $1;
         } elsif ($line =~ /^\s+ volume.size \s = \s (\S+)/x) {
            my $value = $1;
            $device->{TOTAL} = int($value/(1024*1024) + 0.5);
        } elsif ($line =~ /block.is_volume\s*=\s*true/i) {
            $device->{ISVOLUME} = 1;
        }
    }
    close $handle;

    return $devices;
}

1;
