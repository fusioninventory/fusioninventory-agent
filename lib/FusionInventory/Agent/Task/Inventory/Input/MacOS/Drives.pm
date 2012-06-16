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
        next unless /(disk \d+ s \d+)$/x;
        my $id = $1;
        my $name = "/dev/$1";

        my $filesystem = $filesystems{$name};
        next unless $filesystem;

        my $device;
        foreach (`diskutil info $id`) {
            next unless /(\S[^:]+) : \s+ (\S.*\S)/x;
            $device->{$1} = $2;
        }

        my $size;
        if ($device->{'Total Size'} =~ /^([.\d]+ \s \S+)/x) {
            $size = getCanonicalSize($1);
        }

        $filesystem->{TOTAL}      = $size;
        $filesystem->{SERIAL}     = $device->{'Volume UUID'} ||
                                    $device->{'UUID'};
        $filesystem->{FILESYSTEM} = $device->{'File System'} ||
                                    $device->{'Partition Type'};
        $filesystem->{LABEL}      = $device->{'Volume Name'};
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
