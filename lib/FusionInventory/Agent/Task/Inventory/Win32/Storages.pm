package FusionInventory::Agent::Task::Inventory::Win32::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $hdparm = canRun('hdparm');

    foreach my $storage (_getDisks()) {
        if ($hdparm && $storage->{NAME} =~ /(\d+)$/) {
	    my $info = _getInfo("hd", $1);
	    $storage->{MODEL}    = $info->{model}    if $info->{model};
	    $storage->{FIRMWARE} = $info->{firmware} if $info->{firmware};
	    $storage->{SERIAL}   = $info->{serial}   if $info->{serial};
	    $storage->{DISKSIZE} = $info->{size}     if $info->{size};
        }

        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
	);
    }

    foreach my $storage (_getCDROMs()) {
        if ($hdparm && $storage->{NAME} =~ /(\d+)$/) {
            my $info = _getInfo("cdrom", $1);
	    $storage->{MODEL}    = $info->{model}    if $info->{model};
	    $storage->{FIRMWARE} = $info->{firmware} if $info->{firmware};
	    $storage->{SERIAL}   = $info->{serial}   if $info->{serial};
	    $storage->{DISKSIZE} = $info->{size}     if $info->{size};
        }

        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
	);
    }

    foreach my $storage (_getTapes()) {
        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
	);
    }
}

sub _getDisks {
    my @disks;

    foreach my $object (getWMIObjects(
        class      => 'Win32_DiskDrive',
        properties => [ qw/
            Manufacturer Model Description Name MediaType InterfaceType
	    FirmwareRevision SerialNumber Size
	    SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $object->{SerialNumber} = undef
            if $object->{SerialNumber} && $object->{SerialNumber} =~ /^ +$/;

	push @disks, {
	    MANUFACTURER => $object->{Manufacturer},
	    MODEL        => $object->{Model},
	    DESCRIPTION  => $object->{Description},
	    NAME         => $object->{Name},
	    TYPE         => $object->{MediaType},
	    INTERFACE    => $object->{InterfaceType},
	    FIRMWARE     => $object->{FirmwareRevision},
	    SERIAL       => $object->{SerialNumber},
	    DISKSIZE     => $object->{Size},
	    SCSI_COID    => $object->{SCSIPort},
	    SCSI_LUN     => $object->{SCSILogicalUnit},
	    SCSI_UNID    => $object->{SCSITargetId},
	}
    }

    return @disks;
}

sub _getCDROMs {
    my @cdroms;

    foreach my $object (getWMIObjects(
        class      => 'Win32_CDROMDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size
	    SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $object->{SerialNumber} = undef
            if $object->{SerialNumber} && $object->{SerialNumber} =~ /^ +$/;

	push @cdroms, {
	    MANUFACTURER => $object->{Manufacturer},
	    MODEL        => $object->{Caption},
	    DESCRIPTION  => $object->{Description},
	    NAME         => $object->{Name},
	    TYPE         => $object->{MediaType},
	    INTERFACE    => $object->{InterfaceType},
	    FIRMWARE     => $object->{FirmwareRevision},
	    SERIAL       => $object->{SerialNumber},
	    DISKSIZE     => $object->{Size},
	    SCSI_COID    => $object->{SCSIPort},
	    SCSI_LUN     => $object->{SCSILogicalUnit},
	    SCSI_UNID    => $object->{SCSITargetId},
	};
    }

    return @cdroms;
}

sub _getTapes {
    my @tapes;

    foreach my $object (getWMIObjects(
        class      => 'Win32_TapeDrive',
        properties => [ qw/
            Manufacturer Caption Description Name MediaType InterfaceType
            FirmwareRevision SerialNumber Size
	    SCSIPort SCSILogicalUnit SCSITargetId
        / ]
    )) {

        $object->{Size} = int($object->{Size} / (1024 * 1024))
            if $object->{Size};

        $object->{SerialNumber} = undef
            if $object->{SerialNumber} && $object->{SerialNumber} =~ /^ +$/;

	push @tapes, {
	    MANUFACTURER => $object->{Manufacturer},
	    MODEL        => $object->{Caption},
	    DESCRIPTION  => $object->{Description},
	    NAME         => $object->{Name},
	    TYPE         => $object->{MediaType},
	    INTERFACE    => $object->{InterfaceType},
	    FIRMWARE     => $object->{FirmwareRevision},
	    SERIAL       => $object->{SerialNumber},
	    DISKSIZE     => $object->{Size},
	    SCSI_COID    => $object->{SCSIPort},
	    SCSI_LUN     => $object->{SCSILogicalUnit},
	    SCSI_UNID    => $object->{SCSITargetId},
	};
    }

    return @tapes;
}

sub _getInfo {
    my ($type, $nbr) = @_;


    my $device = "/dev/";
    $device .= $type eq 'hd'?'hd':'scd';
    $device .= chr(ord('a')+$nbr);

    my $handle = getFileHandle(
        command => "hdparm -I $device",
    );
    return unless $handle;

    my $info;
    while (my $line = <$handle>) {
        $info->{model} = $1 if $line =~ /Model Number:\s+(.*?)\s*$/;
        $info->{firmware} = $1 if $line =~ /Firmware Revision:\s+(\S*)/;
        $info->{serial} = $1 if $line =~ /Serial Number:\s+(\S*)/;
        $info->{size} = $1 if $line =~ /1000:\s+(\d*)\sMBytes\s\(/;
    }
    close $handle;

    return $info;
}

1;
