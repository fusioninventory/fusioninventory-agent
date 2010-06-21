package FusionInventory::Agent::Task::Inventory::OS::Linux::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return unless can_run ("df");
    my $df = `df -TP`;
    return 1 if $df =~ /\w+/;
    return 0;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    my @drives = getFromDF();

    if (can_run ("lshal")) {
       # index devices by name for comparaison
        my %drives = map { $_->{VOLUMN} => $_ } @drives;

        # complete with hal for missing bits
        foreach my $drive (getFromHal()) {
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

sub getFromHal {
    my $devices = parseLshal('/usr/bin/lshal', '-|');
    return @$devices;
}

sub getFromDF {

    my @drives;

    my %months = (
        Jan => 1,
        Fev => 2,
        Mar => 3,
        Apr => 4,
        May => 5,
        Jun => 6,
        Aug => 7,
        Sep => 8,
        Nov => 9,
        Dec => 12,
    );

    foreach(`df -TP`) { # TODO retrive error
        my $createdate;
        my $free;
        my $filesystem;
        my $label;
        my $total;
        my $type;
        my $volumn;
        my $serial;

        if(/^(\S+)\s+(\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\n/) {
            $free = sprintf("%i",($4/1024));
            $filesystem = $2;
            $total = sprintf("%i",($3/1024));
            $type = $5;
            $volumn = $1;

            # no virtual FS
            next if ($filesystem =~ /^(tmpfs|usbfs|proc|devpts|devshm|udev)$/);
            next if ($type =~ /^(tmpfs)$/);

            if (can_run('blkid')) {
                my $tmp = `blkid $volumn 2> /dev/null`;
                $serial = $1 if ($tmp =~ /\sUUID="(\S*)"\s/);
            } elsif ($filesystem =~ /^ext(2|3|4|4dev)/ && can_run('dumpe2fs')) {
                # tune2fs -l /dev/hda1 give the same output and should be call as
                # alternative solution
                foreach (`dumpe2fs -h $volumn 2> /dev/null`) {
                    if (/Filesystem UUID:\s+(\S+)/) {
                        $serial = $1;
                    } elsif (/Filesystem created:\s+\w+\s+(\w+)\s+(\d+)\s+([\d:]+)\s+(\d{4})$/) {
                        $createdate = $4.'/'.$months{$1}.'/'.$2.' '.$3;
                    } elsif (/Filesystem volume name:\s*(\S.*)/) {
                        $label = $1 unless $1 eq '<none>';
                    }
                }
            } elsif ($filesystem =~ /^xfs$/ && can_run('xfs_db')) {
                foreach (`xfs_db -r -c uuid $volumn`) {
                    $serial = $1 if /^UUID =\s+(\S+)/;
                }
                foreach (`xfs_db -r -c label $volumn`) {
                    $label = $1 if /^label =\s+"(\S+)"/;
                }
            } elsif ($filesystem =~ /^vfat$/ && can_run('dosfslabel')) {
                chomp ($label = `dosfslabel $volumn`);
            }

            $label =~ s/\s+$// if $label;
            $serial =~ s/\s+$// if $serial;

            push @drives, {
                VOLUMN     => $volumn,
                FILESYSTEM => $filesystem,
                LABEL      => $label,
                SERIAL     => $serial,
                TYPE       => $type,
                TOTAL      => $total,
            };
        }
    }

    return @drives;
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
        if ($line =~ m{^udi = '/org/freedesktop/Hal/devices/volume.*}) {
            $device = {};
            next;
        }

        next unless defined $device;

        if ($line =~ /^$/) {
            push(@$devices, $device);
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
        }
    }
    close $handle;

    return $devices;
}

1;
