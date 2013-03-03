package FusionInventory::Agent::Task::Inventory::Linux::Videos;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $ddcprobeData = _getDdcprobeData(
        command => 'ddcprobe',
        logger  => $logger
    );
    my $xorgData;

    my $xorgPid;
    foreach my $process (getProcesses(logger  => $logger)) {
        next unless $process->{CMD} =~ m{
            ^
            (?:
                /usr/bin
                |
                /usr/X11R6/bin
                |
                /etc/X11
            )
            /X
        }x;
        $xorgPid = $process->{PID};
        last;
    }

    if ($xorgPid) {
        my $link = "/proc/$xorgPid/fd/0";
        $xorgData = _parseXorgFd(file => $link) if -r $link;
    }

    return unless $xorgData || $ddcprobeData;

    my $video = {
        CHIPSET    => $xorgData->{product}    || $ddcprobeData->{product},
        MEMORY     => $xorgData->{memory}     || $ddcprobeData->{memory},
        NAME       => $xorgData->{name}       || $ddcprobeData->{oem},
        RESOLUTION => $xorgData->{resolution} || $ddcprobeData->{dtiming},
        PCISLOT    => $xorgData->{pcislot},
    };

    if ($video->{MEMORY} && $video->{MEMORY} =~ s/kb$//i) {
        $video->{MEMORY} = int($video->{MEMORY} / 1024);
    }
    if ($video->{RESOLUTION}) {
        $video->{RESOLUTION} =~ s/@.*//;
    }

    $inventory->addEntry(
        section => 'VIDEOS',
        entry   => $video
    );
}

sub _getDdcprobeData {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $data;
    while (my $line = <$handle>) {
        $line =~ s/[[:cntrl:]]//g;
        $line =~ s/[^[:ascii:]]//g;
        $data->{$1} = $2 if $line =~ /^(\S+):\s+(.*)/;
    }
    close $handle;

    return $data;
}

sub _parseXorgFd {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $data;
    while (my $line = <$handle>) {
        if ($line =~ /Modeline\s"(\S+?)"/) {
            $data->{resolution} = $1 if !$data->{resolution};
        } elsif ($line =~ /Integrated Graphics Chipset:\s+(.*)/) {
            # Intel
            $data->{name} = $1;
        } elsif ($line =~ /Virtual screen size determined to be (\d+)\s*x\s*(\d+)/) {
            # Nvidia
            $data->{resolution} = "$1x$2";
        } elsif ($line =~ /NVIDIA GPU\s*(.*?)\s*at/) {
            $data->{name} = $1;
        } elsif ($line =~ /VESA VBE OEM:\s*(.*)/) {
            $data->{name} = $1;
        } elsif ($line =~ /VESA VBE OEM Product:\s*(.*)/) {
            $data->{product} = $1;
        } elsif ($line =~ /VESA VBE Total Mem: (\d+)\s*(\w+)/i) {
            $data->{memory} = $1 . $2;
        } elsif ($line =~ /RADEON\(0\): Chipset: "(.*?)"/i) {
            # ATI /Radeon
            $data->{name} = $1;
        } elsif ($line =~ /Virtual size is (\S+)/i) {
            # VESA / XFree86
            $data->{resolution} = $1;
        } elsif ($line =~ /Primary Device is: PCI (.+)/i) {
            $data->{pcislot} = $1;
            # mimic lspci pci slot format
            $data->{pcislot} =~ s/^00@//;
            $data->{pcislot} =~ s/(\d{2}):(\d{2}):(\d)$/$1:$2.$3/;
        } elsif ($line =~ /NOUVEAU\(0\): Chipset: "(.*)"/) {
            # Nouveau
            $data->{product} = $1;
        }
    }
    close $handle;

    return $data;
}

1;
