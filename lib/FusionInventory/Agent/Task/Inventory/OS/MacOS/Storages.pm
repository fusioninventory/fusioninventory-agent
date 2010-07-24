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
    foreach (`/usr/sbin/system_profiler SPSerialATADataType`, `/usr/sbin/system_profiler SPParallelATADataType`) {
        if (/^\s*$/) {
            $wasEmpty=1;
            next;
        }


        next unless /^(\s*)/;
        if ($1 ne $revIndent) {
            $name = $1 if (/^\s+(\S+):\s*$/ && $wasEmpty);
            $revIndent = $1;
# We use the Protocol key to know if it a storage section or not
            if ($info->{Protocol}) {
                push @infos, $info;
                $info = {};
                $name = '';
            }
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
            if ( ($device->{'Protocol'} eq 'ATAPI')
                    ||
                    ($device->{'Drive Type'}) ) {
                $description = 'CD-ROM Drive';
            } else {
                $description = 'Disk drive';
            }

            my $size = $device->{'Capacity'};
            if ($size) {
                $size =~ s/ GB//;
                $size =~ s/,/./;
                $size = int($size * 1024);
            }

            my $manufacturer = getManufacturer($device->{'Name'});

            my $model = $device->{'Model'};
            $model =~ s/\s*$manufacturer\s*//i;

        $inventory->addStorages({
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
