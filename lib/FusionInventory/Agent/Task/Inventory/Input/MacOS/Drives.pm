package FusionInventory::Agent::Task::Inventory::Input::MacOS::Drives;

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

    # get filesystem types
    my @types = 
        grep { ! /^(?:fdesc|devfs|procfs|linprocfs|linsysfs|tmpfs|fdescfs)$/ }
        getFilesystemsTypesFromMount(logger => $logger);

    # get filesystems for each type
    my @filesystems;
    foreach my $type (@types) {
        push @filesystems, getFilesystemsFromDf(
            logger  => $logger,
            command => "df -P -k -t $type",
            type    => $type,
        );
    }

    my %filesystems = map { $_->{VOLUMN} => $_ } @filesystems;

    # get additional informations
    foreach (`diskutil list`) {
        # partition identifiers look like disk0s1
        next unless /(disk \d+ s \d+)$/;
        my $id = $1;
        my $name = "/dev/$1";

        my $device;
        foreach (`diskutil info $id`) {
            next unless /^\s+(.*?):\s*(\S.*)/;
            $device->{$1} = $2;
        }

        my $size;
        if ($device->{'Total Size'} =~ /^(.*) \s \(/x) {
            $size = getCanonicalSize($1);
        }

        $filesystems{$name}->{TOTAL}      = $size;
        $filesystems{$name}->{SERIAL}     = $device->{'Volume UUID'} ||
                                       $device->{'UUID'};
        $filesystems{$name}->{FILESYSTEM} = $device->{'File System'} ||
                                       $device->{'Partition Type'};
        $filesystems{$name}->{LABEL}      = $device->{'Volume Name'};
    }

    # add filesystems to the inventory
    foreach my $key (keys %filesystems) {
        $inventory->addEntry(
            section => 'DRIVES',
            entry   => $filesystems{$key}
        );
    }
}

1;
