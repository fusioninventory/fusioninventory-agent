package FusionInventory::Agent::Task::Inventory::OS::MacOS::Storages;

use strict;
use warnings;

sub isInventoryEnabled {1}

sub getManufacturer {
    my $model = shift;
    if($model =~ /(maxtor|western|sony|compaq|hewlett packard|ibm|seagate|toshiba|fujitsu|lg|samsung|nec|transcend|matshita|pioneer)/i) {
        return ucfirst(lc($1));
    }
    elsif ($model =~ /^HP/) {
        return "Hewlett Packard";
    }
    elsif ($model =~ /^WDC/) {
        return "Western Digital";
    }
    elsif ($model =~ /^ST/) {
        return "Seagate";
    }
    elsif ($model =~ /^HD/ or $model =~ /^IC/ or $model =~ /^HU/) {
        return "Hitachi";
    }
}

sub getDiskInfo {
    my ($section) = @_;

    my $wasEmpty;
    my $revIndent = '';
    my @infos;
    my $info;
    my $name;
    foreach (`/usr/sbin/system_profiler SPSerialATADataType`,
        `/usr/sbin/system_profiler SPParallelATADataType`,
        `/usr/sbin/system_profiler SPUSBDataType`) {
        if (/^\s*$/) {
            $wasEmpty=1;
            next;
        }


        next unless /^(\s*)/;
        if ($1 ne $revIndent) {
            $name = $1 if (/^\s+(\S+.*\S+):\s*$/ && $wasEmpty);
            $revIndent = $1;

# We use the Protocol key to know if it a storage section or not
            if ($info->{Protocol} || ($info->{'BSD Name'} && $info->{'Product ID'})) {
                $info->{Protocol} = 'USB' if $info->{'Product ID'};
                push @infos, $info;
                $name = '';
            }
            $info = {};
        }
        if (/^\s+(\S+.*?):\s+(\S.*)/) {
            $info->{$1}=$2;
            $info->{Name} = $name;
        }
        $wasEmpty=0;
    }
# The last one
    if ($info->{Protocol}) {
        push @infos, $info;
    }

    return \@infos;
}


sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $devices = {};

    # Get SATA Drives
    my $sata = getDiskInfo();

    foreach my $device ( @$sata ) {
            my $description;
            my $type; # To improve
            if ( ($device->{'Protocol'} eq 'ATAPI')
                    ||
                    ($device->{'Drive Type'}) ) {
                $description = 'CD-ROM Drive';
            } elsif ($device->{'Protocol'} eq 'USB') {
                $description = 'USB drive';
                $type = 'USB';
            } else {
                $description = 'Disk drive';
            }

            my $size = $device->{'Capacity'};
            if ($size) {
                #e.g: Capacity: 320,07 GB (320 072 933 376 bytes)
                $size =~ s/\s*\(.*//;
                $size =~ s/ GB//;
                $size =~ s/,/./;
                $size = int($size * 1024);
            }

            my $manufacturer = getManufacturer($device->{'Name'});

            my $model = $device->{'Model'};
            if ($model) {
                $model =~ s/\s*$manufacturer\s*//i;
            }

        $inventory->addStorage({
                NAME => $device->{'Name'},
                SERIAL => $device->{'Serial Number'},
                DISKSIZE => $size,
                FIRMWARE => $device->{'Revision'},
                MANUFACTURER => $manufacturer,
                DESCRIPTION => $description,
                MODEL => $model
            });
    }


}

1;
