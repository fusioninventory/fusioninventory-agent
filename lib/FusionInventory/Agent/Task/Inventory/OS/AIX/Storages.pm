package FusionInventory::Agent::Task::Inventory::OS::AIX::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return
        can_run('lsdev') &&
        can_run('lsattr');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    # index VPD infos by AX field
    my %infos =
        map  { $_->{AX} => $_ }
        grep { $_->{AX} }
        getLsvpdInfos(logger => $logger);  

    # SCSI disks 
    foreach my $disk (_getDisks(
        subclass => 'scsi',
        logger   => $logger,
    )) {
        $disk->{DISKSIZE}     = _getCapacity($disk->{NAME}, $logger);
        $disk->{MANUFACTURER} = _getManufacturer(infos{$disk->{NAME}});
        $disk->{MODEL}        = _getModel(infos{$disk->{NAME}});

        $disk->{SERIAL} = getFirstMatch(
            command => "lscfg -p -v -s -l $disk->{NAME}",
            logger  => $logger,
            pattern => qr/Serial Number\.*(.*)/
        );

        $inventory->addEntry(section => 'STORAGES', entry => $disk);
    }

    # FCP disks
    foreach my $disk (_getDisks(
        subclass => 'fcp',
        logger   => $logger
    )) {
        $disk->{MANUFACTURER} = _getManufacturer(infos{$disk->{NAME}});
        $disk->{MODEL}        = _getModel(infos{$disk->{NAME}});

        $inventory->addEntry(section => 'STORAGES', entry => $disk);
    }

    # FDAR disks
    foreach my $disk (_getDisks(
        subclass => 'fdar',
        logger   => $logger
    )) {
        $disk->{MANUFACTURER} = _getManufacturer(infos{$disk->{NAME}});
        $disk->{MODEL}        = _getModel(infos{$disk->{NAME}});

        $inventory->addEntry(section => 'STORAGES', entry => $disk);
    }

    # SAS disks
    foreach my $disk (_getDisks(
        subclass => 'sas',
        logger   => $logger
    )) {
        $disk->{MANUFACTURER} = _getManufacturer(infos{$disk->{NAME}});
        $disk->{MODEL}        = _getModel(infos{$disk->{NAME}});

        $inventory->addEntry(section => 'STORAGES', entry => $disk);
    }

    # Virtual disks
    foreach my $disk (_getDisks(
        subclass => 'vscsi',
        logger   => $logger
    )) {
        my $model;
        my $capacity;

        my @lsattr = getAllLines(
            command => "lspv $disk->{NAME}",
            logger  => $logger
        );
        foreach (@lsattr) {
            if ( ! ( /^0516-320.*/ ) ) {
                if (/TOTAL PPs:/ ) {
                    ($capacity, $model) = split(/\(/, $_);
                    ($capacity, $model) = split(/ /, $model);
                }
            } else {
                $capacity = 0;
            }
        }

        $disk->{MANUFACTURER} = "VIO Disk";
        $disk->{MODEL} = "Virtual Disk";
        $disk->{DISKSIZE} = $capacity;

        $inventory->addEntry(section => 'STORAGES', entry => $disk);
    }

    # CDROM
    foreach my $cdrom (_getRemovableMedias(
        class    => 'cdrom',
        subclass => 'scsi',
        logger   => $logger
    )) {
        $cdrom->{TYPE}         = 'cd';
        $cdrom->{DISKSIZE}     = _getCapacity($cdrom->{NAME}, $logger);
        $cdrom->{MANUFACTURER} = _getManufacturer(infos{$cdrom->{NAME}});
        $cdrom->{MODEL}        = _getModel(infos{$cdrom->{NAME}});

        $inventory->addEntry(section => 'STORAGES', entry => $cdrom);
    }

    # tapes
    foreach my $tape (_getRemovableMedias(
        class    => 'tape',
        subclass => 'scsi',
        logger   => $logger
    )) {
        $tape->{TYPE} = 'tape';
        $tape->{DISKSIZE}     = _getCapacity($tape->{NAME}, $logger);
        $tape->{MANUFACTURER} = _getManufacturer(infos{$tape->{NAME}});
        $tape->{MODEL}        = _getModel(infos{$tape->{NAME}});

        $inventory->addEntry(section => 'STORAGES', entry => $tape);
    }

    # floppies
    foreach my $floppy (_getRemovableMedias(
        class    => 'diskette',
        logger   => $logger
    )) {
        $floppy->{TYPE} = 'floppy';

        $inventory->addEntry(section => 'STORAGES', entry => $floppy);
    }
}

sub _getCapacity {
    my ($device, $logger) = @_;

    return getLastLine(
        command => "lsattr -EOl $device -a 'size_in_mb'",
        logger  => $logger
    );
}

sub _getManufacturer {
    my ($device) = @_;

    return unless $device;

    return $device->{FN} ?
        "$device->{MF},FRU number :$device->{FN}" :
        "$device->{MF}"                           ;
}

sub _getModel {
    my ($device) = @_;

    return unless $device;

    return $device->{TM};
}

sub _getDisks {
    my %params = @_;

    my @disks;

    my $command = "lsdev -Cc disk -s $params{subclass} -F 'name:description'";

    foreach my $line (getAllLines(
        command => $command,
        @_
    )) {
        chomp $line;
        next unless $line =~ /^(.+):(.+)/;
        my $device = $1;
        my $description = $2;

        push @disks, {
            NAME        => $device,
            DESCRIPTION => $description,
            TYPE        => 'disk',
        };
    }

    return @disks;
}

sub _getRemovableMedias {
    my %params = @_;

    my @medias;

    my $command = $params{subclass} ?
        "lsdev -Cc $params{class} -s $params{subclass} -F 'name:description:status'" :
        "lsdev -Cc $params{class}                      -F 'name:description:status'" ;

    foreach my $line (getAllLines(
        command => $command,
        @_
    )) {
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;

        push @medias, {
            NAME        => $device,
            DESCRIPTION => $description,
            TYPE        => $params{type}
        };
    }

    return @medias;
}

1;
