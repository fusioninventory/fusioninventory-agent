package FusionInventory::Agent::Task::Inventory::Input::AIX::LVM;

use FusionInventory::Agent::Tools;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isEnabled {
    canRun("lspv");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $volume (_getPhysicalVolumes($logger)) {
        $inventory->addEntry(section => 'PHYSICAL_VOLUMES', entry => $volume);
    }

    foreach my $volume (_getLogicalVolumes($logger)) {
        $inventory->addEntry(section => 'LOGICAL_VOLUMES', entry => $volume);
    }

    foreach my $group (_getVolumeGroups($logger)) {
        $inventory->addEntry(section => 'VOLUME_GROUPS', entry => $group);
    }

}

sub _getLogicalVolumes {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => "lsvg",
        logger  => $logger
    );
    return unless $handle;

    my @volumes;

    foreach my $line (<$handle>) {
        chomp $line;
        push @volumes, _getLogicalVolume($logger, $line);
    }
    close $handle;

    return @volumes;
}

sub _getLogicalVolume {
    my ($logger, $name) = @_;

    my $handle = getFileHandle(
        command => "lsvg -l $name",
        logger  => $logger
    );
    return unless $handle;

    my $volume;

    foreach my $line (<$handle>) {
        chomp $line;

        if ($line =~ /(\S+):/) {
            $volume->{VG_UUID} = $1;
        }
        if ($line !~ !/^LV NAME/ && $line =~ /(\S+) *(\S+) *(\d+) *(\d+) *(\d+) *(\S+) *(\S+)/) {
            $volume->{LV_NAME}   = $1;
            $volume->{SEG_COUNT} = $3;
            $volume->{ATTR}      = "Type $2,PV: $5";
        }
    }
    close $handle;

    my $size;
    foreach (`lslv $volume->{LV_NAME}`) {
        if (/.*PP SIZE:\s+(\d+) .*/) {
            $size = $1;
        }
        if (/LV IDENTIFIER:\s+(\S+)/) {
            $volume->{LV_UUID} = $1;
        }
    }

    $volume->{SIZE} = int($volume->{SEG_COUNT} * $size);

    return $volume;
}

sub _getPhysicalVolumes {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => "lspv | cut -f1 -d' '",
        logger  => $logger
    );
    return unless $handle;

    my @volumes;

    foreach my $line (<$handle>) {
        chomp $line;
        push @volumes, _getPhysicalVolume($logger, $line);
    }
    close $handle;

    return @volumes;
}

sub _getPhysicalVolume {
    my ($logger, $name) = @_;

    my $handle = getFileHandle(
        command => "lspv $name",
        logger  => $logger
    );
    return unless $handle;

    my $volume = {
        DEVICE  => "/dev/$name",
        PV_NAME => $name,
    };

    my ($free, $total);
    foreach my $line (<$handle>) {
        chomp $line;

        if ($line =~ /PHYSICAL VOLUME:\s+(\S+)/) {
            $volume->{FORMAT} = "AIX PV $1";
        }
        if ($line =~ /FREE PPs:\s+(\d+)/) {
            $free = $1;
        }
        if ($line =~ /TOTAL PPs:\s+(\d+)/) {
            $total = $1;
        }
        if ($line =~ /VOLUME GROUP:\s+(\S+)/) {
            $volume->{ATTR} = "VG $1";
        }
        if ($line =~ /PP SIZE:\s+(\d+)/) {
            $volume->{PE_SIZE} = $1;
        }
        if ($line =~ /PV IDENTIFIER:\s+(\S+)/) {
            $volume->{PV_UUID} = $1;
        }
    }
    close $handle;

    $volume->{SIZE} = $total * $volume->{PE_SIZE};
    $volume->{FREE} = $free * $volume->{PE_SIZE};
    $volume->{PV_PE_COUNT} = $total;

    return $volume;
}

sub _getVolumeGroups {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => 'lsvg',
        logger  => $logger
    );
    return unless $handle;

    my @groups;

    foreach my $line (<$handle>) {
        chomp $line;
        push @groups, _getVolumeGroup($logger, $line);
    }
    close $handle;

    return @groups;
}

sub _getVolumeGroup {
    my ($logger, $name) = @_;

    my $handle = getFileHandle(
        command => "lsvg $name",
        logger  => $logger
    );
    return unless $handle;

    my $group = {
        VG_NAME => $name
    };

    foreach my $line (<$handle>) {
        chomp $line;

        if ($line =~ /TOTAL PPs:\s+(\d+)/) {
            $group->{SIZE} = $1;
        }
        if ($line =~ /FREE PPs:\s+(\d+)/) {
            $group->{FREE} = $1;
        }
        if ($line =~ /VG IDENTIFIER:\s+(\S+)/) {
            $group->{VG_UUID} = $1;
        }
        if ($line =~ /PP SIZE:\s+(\d+)/) {
            $group->{VG_EXTENT_SIZE} = $1;
        }
        if ($line =~ /LVs:\s+(\d+)/) {
            $group->{LV_COUNT} = $1;
        }
        if ($line =~/ACTIVE PVs:\s+(\d+)/) {
            $group->{PV_COUNT} = $1;
        }

    }
    close $handle;

    return $group;
}

1;
