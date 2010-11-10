package FusionInventory::Agent::Task::Inventory::OS::MacOS::Drives;

use strict;
use warnings;

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

    my $free;
    my $filesystem;
    my $total;
    my $type;
    my $volumn;
    my %drives;
    my %storages;
    my %diskUtilDevices;

    my %fs;
    foreach (`mount`) {
	next if /^devfs/;
	next if /^fdesc/;
        if (/on\s.+\s\((\S+?)(,|\))/) {
            $fs{$1} = 1;
        }
    }

    for my $t (keys %fs) {
        # OpenBSD has no -m option so use -k to obtain results in kilobytes
        for(`df -P -k -t $t`){ # darwin needs the -t to be last
            if(/^(\/\S*)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S.+)\n/){
                $type = $6;
                $filesystem = $t;
                $total = sprintf("%i",$2/1024);
                $free = sprintf("%i",$4/1024);
                $volumn = $1;

                $drives{$volumn} = {
                    FREE => $free,
                    FILESYSTEM => $filesystem,
                    TOTAL => $total,
                    TYPE => $type,
                    VOLUMN => $volumn
                }

            }
        }
    }

    foreach (`diskutil list`) {
        if (/\d+:\s+.*\s+(\S+)/) {
            my $deviceName = "/dev/$1";
            foreach (`diskutil info $1`) {
                $diskUtilDevices{$deviceName}->{$1} = $2 if /^\s+(.*?):\s*(\S.*)/;
            }
        }
    }

    foreach my $deviceName (keys %diskUtilDevices) {
        my $device = $diskUtilDevices{$deviceName};
        my $size;

        my $isHardDrive;

        if ((defined($device->{'Part Of Whole'}) && ($device->{'Part Of Whole'} eq $device->{'Device Identifier'}))) {
            # Is it possible to have a drive without partition?
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
            $drives{$deviceName}->{SERIAL} = $device->{'Volume UUID'} || $device->{'UUID'};
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
