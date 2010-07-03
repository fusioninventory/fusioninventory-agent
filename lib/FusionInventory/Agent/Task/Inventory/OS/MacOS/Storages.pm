package FusionInventory::Agent::Task::Inventory::OS::MacOS::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return can_load('Mac::SysProfile');
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $devices = {};

    my $prof = Mac::SysProfile->new();

    # Get SATA Drives
    my $sata = $prof->gettype('SPSerialATADataType');

    return unless( ref($sata) eq 'HASH' );

    foreach my $x ( keys %$sata ) {
        my $controller = $sata->{$x};
        foreach my $y ( keys %$controller ) {
            next unless( ref($sata->{$x}->{$y}) eq 'HASH' );
            my $drive = $sata->{$x}->{$y};

            my $description;
            if ( $y =~ /DVD/i || $y =~ /CD/i ) {
                $description = 'CD-ROM Drive';
            }
            else {
                $description = 'Disk drive';
            }

            my $size = $drive->{'Capacity'};
            $size =~ s/ GB//;
            $size *= 1024;

            my $manufacturer = getManufacturer($y);

            my $model = $drive->{'Model'};
            $model =~ s/\s*$manufacturer\s*//i;

            $devices->{$y} = {
                NAME => $y,
                SERIAL => $drive->{'Serial Number'},
                DISKSIZE => $size,
                FIRMWARE => $drive->{'Revision'},
                MANUFACTURER => $manufacturer,
                DESCRIPTION => $description,
                MODEL => $model
            };
        }
    }

    # Get PATA Drives
    my $pata = $prof->gettype('SPParallelATADataType');

    foreach my $x ( keys %$pata ) {
        my $controller = $pata->{$x};
        foreach my $y ( keys %$controller ) {
            next unless ( ref($pata->{$x}->{$y}) eq 'HASH' );
            my $drive = $pata->{$x}->{$y};

            my $description;
            if ( $y =~ /DVD/i || $y =~ /CD/i ) {
                $description = 'CD-ROM Drive';
            }
            else {
                $description = 'Disk drive';
            }

            my $manufacturer = getManufacturer($y);

            my $model = $drive->{'Model'};

            my $size;

            $devices->{$y} = {
                NAME => $y,
                SERIAL => $drive->{'Serial Number'},
                DISKSIZE => $size,
                FIRMWARE => $drive->{'Revision'},
                MANUFACTURER => $manufacturer,
                DESCRIPTION => $description,
                MODEL => $model
            };
        }
    }

    foreach my $device ( keys %$devices ) {
        $inventory->addStorage($devices->{$device});
    }

}

1;
