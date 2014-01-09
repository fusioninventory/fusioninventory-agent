package FusionInventory::Agent::Task::Inventory::AIX::LVM;

use FusionInventory::Agent::Tools;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isEnabled {
    canRun('lspv');
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

    while (my $line = <$handle>) {
        chomp $line;
        foreach my $name (_getLogicalVolumesFromGroup(logger => $logger, name => $line)) {
            push @volumes, _getLogicalVolume(logger => $logger, name => $name);
        }
    }

    close $handle;

    return @volumes;
}

sub _getLogicalVolumesFromGroup {
    my (%params) = @_;

    my $command = $params{name} ? "lsvg -l $params{name}" : undef;
    my $handle = getFileHandle(
        command => $command,
        file    => $params{file},
        logger  => $params{logger}
    );
    return unless $handle;

    # skip headers
    my $line;
    $line = <$handle>;
    $line = <$handle>;

    # no logical volume if there is only one line of output
    return unless $line;

    my @names;

    while (my $line = <$handle>) {
        chomp $line;
        next unless $line =~ /^(\S+)/;
        push @names, $1;
    }
    close $handle;

    return @names;
}

sub _getLogicalVolume {
    my (%params) = @_;

    my $handle = getFileHandle(
        command => "lslv $params{name}",
        logger  => $params{logger}
    );
    return unless $handle;

    my $volume = {
        LV_NAME => $params{name}
    };

    while (my $line = <$handle>) {
        if ($line =~ /PP SIZE:\s+(\d+)/) {
            $volume->{SIZE} = $1;
        }
        if ($line =~ /LV IDENTIFIER:\s+(\S+)/) {
            $volume->{LV_UUID} = $1;
        }
    }
    close $handle;

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

    while (my $line = <$handle>) {
        chomp $line;
        push @volumes, _getPhysicalVolume(logger => $logger, name => $line);
    }
    close $handle;

    return @volumes;
}

sub _getPhysicalVolume {
    my (%params) = @_;

    my $command = $params{name} ? "lspv $params{name}" : undef;
    my $handle = getFileHandle(
        command => $command,
        file    => $params{file},
        logger  => $params{logger}
    );
    return unless $handle;

    my $volume = {
        DEVICE  => "/dev/$params{name}"
    };

    my ($free, $total);
    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /PHYSICAL VOLUME:\s+(\S+)/) {
            $volume->{FORMAT} = "AIX PV";
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

    if (defined $volume->{PE_SIZE}) {
        $volume->{SIZE} = $total * $volume->{PE_SIZE} if defined $total;
        $volume->{FREE} = $free * $volume->{PE_SIZE} if defined $free;
    }
    $volume->{PV_PE_COUNT} = $total if defined $total;

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

    while (my $line = <$handle>) {
        chomp $line;
        push @groups, _getVolumeGroup(logger => $logger, name => $line);
    }
    close $handle;

    return @groups;
}

sub _getVolumeGroup {
    my (%params) = @_;

    my $command = $params{name} ? "lsvg $params{name}" : undef;
    my $handle = getFileHandle(
        command => $command,
        file    => $params{file},
        logger  => $params{logger}
    );
    return unless $handle;

    my $group = {
        VG_NAME => $params{name}
    };

    while (my $line = <$handle>) {
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
