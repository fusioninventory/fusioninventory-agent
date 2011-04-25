package FusionInventory::Agent::Task::Inventory::OS::MacOS::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get drives list
    my @types = 
        grep { ! /^(?:fdesc|devfs|procfs|linprocfs|linsysfs|tmpfs|fdescfs)$/ }
        getFilesystemsTypesFromMount(logger => $logger);

    my @drives;
    foreach my $type (@types) {
        push @drives, getFilesystemsFromDf(
            logger => $logger,
            command => "df -P -k -t $type"
        );
    }

    my %drives = map { $_->{VOLUMN} => $_ } @drives;

    # get additional informations
    foreach (`diskutil list`) {
        # partition identifiers look like disk0s1
        next unless /(disk \d+ s \d+)$/;
        my $deviceName = "/dev/$1";

        my $device;
        foreach (`diskutil info $1`) {
            next unless /^\s+(.*?):\s*(\S.*)/;
            $device->{$1} = $2;
        }

        my $size;
        if ($device->{'Total Size'} =~ /^(.*) \s \(/x) {
            $size = getCanonicalSize($1);
        }

        $drives{$deviceName}->{TOTAL}      = $size;
        $drives{$deviceName}->{SERIAL}     = $device->{'Volume UUID'} ||
                                             $device->{'UUID'};
        $drives{$deviceName}->{FILESYSTEM} = $device->{'File System'} ||
                                             $device->{'Partition Type'};
        $drives{$deviceName}->{LABEL}      = $device->{'Volume Name'};
    }

    # add drives to the inventory
    foreach my $key (keys %drives) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $drives{$key}
        );
    }
}

1;
