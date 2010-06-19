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

    my %listVolume = ();

    # Get complementary information in hash tab
    if (can_run ("lshal")) {
        %listVolume =
            map { $_->{VOLUMN} => $_ }
            getFromHal();
    }

    foreach(`df -TP`) { # TODO retrive error
        my $createdate;
        my $free;
        my $filesystem;
        my $label;
        my $total;
        my $type;
        my $volumn;
        my $serial;

        if(/^(\S+)\s+(\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\n/){
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
                    ;
                }
                foreach (`xfs_db -r -c label $volumn`) {
                    $label = $1 if /^label =\s+"(\S+)"/;
                }
            } elsif ($filesystem =~ /^vfat$/ && can_run('dosfslabel')) {
                chomp ($label = `dosfslabel $volumn`);
            }

            $label =~ s/\s+$//;
            $serial =~ s/\s+$//;


            # Check information and improve it
            if (keys %listVolume) {
                if ( defined $listVolume{$volumn} ) {
                    if ($filesystem eq '')  { $filesystem = $listVolume{$volumn}->{'volume.fstype'};}
                    if ($label eq '')       { $label = $listVolume{$volumn}->{'volume.label'};}
                    if ($total eq '')       { $total = int($listVolume{$volumn}->{'volume.size'}/(1024*1024) + 0.5);}
                    if ($type eq '')        { $type = $listVolume{$volumn}->{'storage.model'};}
                    if ($serial eq '')      { $serial = $listVolume{$volumn}->{'volume.uuid'};}
                    delete ($listVolume{$volumn});
                }
            }

            $inventory->addDrive({
                CREATEDATE => $createdate,
                FREE => $free,
                FILESYSTEM => $filesystem,
                LABEL => $label,
                TOTAL => $total,
                TYPE => $type,
                VOLUMN => $volumn,
                SERIAL => $serial
            });
        }
    }

    if (can_run ("lshal")) {
        while (my ($k,$v) = each %listVolume ) {
            $inventory->addDrive({
                FILESYSTEM => $v->{'volume.fstype'},
                LABEL => $v->{'volume.label'},
                TOTAL => int ($v->{'volume.size'}/(1024*1024) + 0.5),
                TYPE => $v->{'storage.model'},
                VOLUMN => $k,
                SERIAL => $v->{'volume.uuid'}
            });
        }
    }  
}

sub getFromHal {
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
