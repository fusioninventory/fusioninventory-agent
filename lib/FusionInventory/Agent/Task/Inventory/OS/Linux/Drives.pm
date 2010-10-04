package FusionInventory::Agent::Task::Inventory::OS::Linux::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        can_run ('df') ||
        can_run ('lshal');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @drives = _getFromDF();

    if (can_run ("lshal")) {
       # index devices by name for comparaison
        my %drives = map { $_->{VOLUMN} => $_ } @drives;

        # complete with hal for missing bits
        foreach my $drive (_getFromHal()) {
            my $name = $drive->{VOLUMN};
            foreach my $key (keys %$drive) {
                $drives{$name}->{$key} = $drive->{$key}
                    if !$drives{$name}->{$key};
            }
        }
    }

    foreach my $drive (@drives) {
        $inventory->addDrive($drive);
    }
}

sub _getFromHal {
    my $devices = _parseLshal('/usr/bin/lshal', '-|');
    return @$devices;
}

sub _getFromDF {

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

    my $devices = _parseDf('df -P -T -k', '-|');

    my $has_blkid      = can_run('blkid');
    my $has_dumpe2fs   = can_run('dumpe2fs');
    my $has_xfs_db     = can_run('xfs_db');
    my $has_dosfslabel = can_run('dosfslabel');

    foreach my $device (@$devices) {

        if ($has_blkid) {
            my $line = `blkid $device->{VOLUMN} 2> /dev/null`;
            $device->{SERIAL} = $1 if $line =~ /\sUUID="(\S*)"\s/;
            next;
        }

        if ($device->{FILESYSTEM} =~ /^ext(2|3|4|4dev)/ && $has_dumpe2fs) {
            foreach my $line (`dumpe2fs -h $device->{VOLUMN} 2> /dev/null`) {
                if ($line =~ /Filesystem UUID:\s+(\S+)/) {
                    $device->{SERIAL} = $1;
                } elsif ($line =~ /Filesystem created:\s+\w+\s+(\w+)\s+(\d+)\s+([\d:]+)\s+(\d{4})$/) {
                    $device->{CREATEDATE} = "$4/$months{$1}/$2 $3";
                } elsif ($line =~ /Filesystem volume name:\s*(\S.*)/) {
                    $device->{LABEL} = $1 unless $1 eq '<none>';
                }
            }
            next;
        }

        if ($device->{FILESYSTEM} eq 'xfs' && $has_xfs_db) {
            foreach my $line (`xfs_db -r -c uuid $device->{VOLUMN}`) {
                $device->{SERIAL} = $1 if $line =~ /^UUID =\s+(\S+)/;
            }
            foreach my $line (`xfs_db -r -c label $device->{VOLUMN}`) {
                $device->{LABEL} = $1 if $line =~ /^label =\s+"(\S+)"/;
            }
            next;
        }

        if ($device->{FILESYSTEM} eq 'vfat' && $has_dosfslabel) {
            $device->{LABEL} = `dosfslabel $device->{VOLUMN}`;
            chomp $device->{LABEL};
            next;
        }

    }
    return @$devices;
}

sub _parseDf {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }


    my $devices;

    # drop headers line
    my $line = <$handle>;
    while (my $line = <$handle>) {
        next unless $line =~ /^
        (\S+) \s+ # name
        (\S+) \s+ # type
        (\S+) \s+ # size
         \S+  \s+ # used
        (\S+) \s+ # available
         \S+  \s+ # capacity
        (\S+)     # mount point
        $/x;

        my $volumn     = $1;
        my $filesystem = $2;
        my $total      = sprintf("%i", $3 / 1024);
        my $free       = sprintf("%i", $4 / 1024);
        my $type       = $5;

        # no virtual FS
        next if $filesystem =~ /^(tmpfs|usbfs|proc|devpts|devshm|udev)$/;

        push @$devices, {
            VOLUMN     => $volumn,
            FILESYSTEM => $filesystem,
            TYPE       => $type,
            TOTAL      => $total,
            FREE       => $free,
        };
    }
    close $handle;

    return $devices;
}

sub _parseLshal {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

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
