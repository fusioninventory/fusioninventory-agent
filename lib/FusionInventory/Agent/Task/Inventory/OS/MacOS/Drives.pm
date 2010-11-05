package FusionInventory::Agent::Task::Inventory::OS::MacOS::Drives;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Unix;

# yea BSD theft!!!!
# would have used Mac::SysProfile, but the xml isn't quite fully supported
# the drives come back in apple xml tree's, and the module can't handle it yet (soon as I find the time to fix the patch)

sub isInventoryEnabled {
    return 1;
}

my %unitMatrice = (
    Ti => 1000*1000,
    GB => 1024*1024,
    Gi => 1000,
    GB => 1024,
    Mi => 1,
    MB => 1,
    Ki => 0.001,
);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};


    my %fs;
    foreach my $line (`mount`) {
        next unless $line =~ /\S+ on \S+ \((\S+),/;
	next if $1 eq 'fdesc';
	next if $1 eq 'devfs';
        $fs{$1}=1;
    }

    my @drives;
    foreach my $fs (keys %fs) {
        foreach my $drive (getFilesystemsFromDf(
            logger => $logger, command => "df -P -k -t $fs"
        )) {
            $drive->{FILESYSTEM} = $fs;
            push @drives, $drive;
        }
    }

    my %diskUtilDevices;
    foreach (`diskutil list`) {
        if (/\d+:\s+.*\s+(\S+)/) {
            my $deviceName = "/dev/$1";
            foreach (`diskutil info $1`) {
                $diskUtilDevices{$deviceName}->{$1} = $2 if /^\s+(.*?):\s*(\S.*)/;
            }
        }
    }

    my %drives;

    foreach my $deviceName (keys %diskUtilDevices) {
        my $device = $diskUtilDevices{$deviceName};
        my $size;

        my $isHardDrive;

        if ($device->{'Part Of Whole'} eq $device->{'Device Identifier'}) {
            $isHardDrive = 1;
        }

        if ($device->{'Total Size'} =~ /(\S*)\s(\S+)\s+\(/) {
            if ($unitMatrice{$2}) {
                $size = $1*$unitMatrice{$2};
            } else {
                $logger->error("$2 unit is not defined");
            }
        }


        if (!$isHardDrive) {
            $drives{$deviceName}->{TOTAL} = $size;
            $drives{$deviceName}->{SERIAL} = $device->{'Volume UUID'};
            $drives{$deviceName}->{FILESYSTEM} = $device->{'File System'} || $device->{'Partition Type'};
            $drives{$deviceName}->{VOLUMN} = $deviceName;
            $drives{$deviceName}->{LABEL} = $device->{'Volume Name'};
#        } else {
#            $storages{$deviceName}->{DESCRIPTION} = $device->{'Protocol'};
#            $storages{$deviceName}->{DISKSIZE} = $size;
#            $storages{$deviceName}->{MODEL} = $device->{'Device / Media Name'};
        }
    }



    foreach my $deviceName (keys %drives) {
        $inventory->addDrive($drives{$deviceName});
    }
#    foreach my $deviceName (keys %storages) {
#        $inventory->addStorage($storags{$deviceName});
#    }

}
1;
