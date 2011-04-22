package FusionInventory::Agent::Task::Inventory::OS::AIX::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run('lsdev') &&
        can_run('lsattr');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    # lsvpd
    my @devices = getDevicesFromLsvpd(logger => $logger);  

    # SCSI disks 
    my @scsi_disks = getAllLines(
        command => 'lsdev -Cc disk -s scsi -F "name:description"',
        logger  => $logger
    );
    foreach my $line (@scsi_disks) {
        chomp $line;
        next unless $line =~ /^(.+):(.+)/;
        my $device = $1;
        my $description = $2;

        my ($manufacturer, $model) = _getLsvpdInfos($device, \@devices);

        my $capacity = _getCapacity($device, $logger);

        my $serial;
        foreach (`lscfg -p -v -s -l $device` =~ /Serial Number\.*(.*)/) {
            $serial = $1;
        }

        $inventory->addStorage({
            NAME         => $device,
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            DESCRIPTION  => $description,
            TYPE         => 'disk',
            SERIAL       => $serial,
            DISKSIZE     => $capacity
        });
    }

    my @fcp_disks = getAllLines(
        command => 'lsdev -Cc disk -s fcp -F "name:description"',
        logger  => $logger
    );
    foreach my $line (@fcp_disks) {
        chomp $line;
        next unless $line =~ /^(.+):(.+)/;
        my $device = $1;
        my $description = $2;

        my ($manufacturer, $model) = _getLsvpdInfos($device, \@devices);

        $inventory->addStorage({
            NAME         => $device,
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            DESCRIPTION  => $description,
            TYPE         => 'disk',
        });
    }

    my @fdar_disks = getAllLines(
        command => 'lsdev -Cc disk -s fdar -F "name:description"',
        logger  => $logger
    );
    foreach my $line (@fdar_disks){
        chomp $line;
        next unless $line =~ /^(.+):(.+)/;
        my $device = $1;
        my $description = $2;

        my ($manufacturer, $model) = _getLsvpdInfos($device, \@devices);

        $inventory->addStorage({
            NAME         => $device,
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            DESCRIPTION  => $description,
            TYPE         => 'disk',
        });
    }

    # Virtual disks
    my @vscsi = getAllLines(
        command => 'lsdev -Cc disk -s vscsi -F "name:description"',
        logger => $logger
    );
    foreach my $line (@vscsi) {
        chomp $line;
        next unless $line =~ /^(.+):(.+)/;
        my $device = $1;
        my $description = $2;
        my $model;
        my $capacity;

        my @lsattr = getAllLines(
            command => "lspv $device",
            logger  => $logger
        );
        foreach (@lsattr) {
            if ( ! ( /^0516-320.*/ ) ) {
                if (/TOTAL PPs:/ ) {
                    ($capacity,$model) = split(/\(/, $_);
                    ($capacity,$model) = split(/ /,$model);
                }
            } else {
                $capacity = 0;
            }
        }
        $inventory->addStorage({
            MANUFACTURER => "VIO Disk",
            MODEL        => "Virtual Disk",
            DESCRIPTION  => $description,
            TYPE         => 'disk',
            NAME         => $device,
            DISKSIZE     => $capacity
        });
    }

    # CDROM
    my @cdroms = getAllLines(
        command => 'lsdev -Cc cdrom -s scsi -F "name:description:status"',
        logger  => $logger
    );

    foreach my $line (@cdroms){
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;

        my $capacity = _getCapacity($device, $logger);

        my ($manufacturer, $model) = _getLsvpdInfos($device, \@devices);

        $inventory->addStorage({
            NAME         => $device,
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            DESCRIPTION  => $description,
            TYPE         => 'cd',
            DISKSIZE     => $capacity
        });
    }

    # TAPE
    my @tapes = getAllLines(
        command => 'lsdev -Cc tape -s scsi -F "name:description:status"',
        logger  => $logger
    );
    foreach my $line (@tapes) {
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;

        my $capacity = _getCapacity($device, $logger);

        my ($manufacturer, $model) = _getLsvpdInfos($device, \@devices);

        $inventory->addStorage({
            NAME         => $device,
            MANUFACTURER => $manufacturer,
            MODEL        => $model,
            DESCRIPTION  => $description,
            TYPE         => 'tape',
            DISKSIZE     => $capacity
        });
    }

    # Diskette
    my @diskettes = getAllLines(
        command => 'lsdev -Cc diskette -F "name:description:status"',
        logger  => $logger
    );
    foreach my $line (@diskettes) {
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;
        $inventory->addStorage({
            NAME        => $1,
            DESCRIPTION => $2,
            TYPE        => 'floppy',
        });
    }
}

sub _getCapacity {
    my ($device, $logger) = @_;

    my @lsattr = getAllLinaes(
        command => "lsattr -EOl $device -a 'size_in_mb'",
        logger  => $logger
    );

    my $capacity;
    foreach (@lsattr){
        if (! /^#/ ){
            $capacity= $_;
            chomp($capacity);
            $capacity =~ s/(\s+)$//;
        }
    }

    return $capacity;
}

sub _getLsvpdInfos {
    my ($name, $devices) = @_;

    my $device = first { $_->{AX} eq $name } @$devices;
    return unless $device;

    my $manufacturer = $device->{MF};
    $manufacturer .= ",FRU number :$device->{FN}" if $device->{FN};

    my $model = $device->{TM};

    return ($manufacturer, $model);
}

1;
