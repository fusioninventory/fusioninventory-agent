package FusionInventory::Agent::Task::Inventory::Input::MacOS::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $storage (_getStorages(logger => $logger)) {
        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
        );
    }
}

sub _getStorages {
    my $infos = getSystemProfilerInfos(@_);

    # system profiler info is organized as
    # bus => {
    #     controller => {
    #         key1 => value1,
    #         device => {
    #             key1 => value1
    #             subdevice => {
    #                 key1 => value1,
    #             }
    #         }
    #     }
    # }
    my @storages;

    foreach my $bus_name (qw/ATA SERIAL-ATA USB FireWire/) {
        my $bus = $infos->{$bus_name};
        next unless $bus;
        foreach my $controller_name (keys %{$bus}) {
            my $controller = $bus->{$controller_name};
            foreach my $device_name (keys %{$controller}) {
                my $device = $controller->{$device_name};
                next unless ref $device eq 'HASH';
                if (_isStorage($device)) {
                    push @storages,
                        _getStorage($device, $device_name, $bus_name);
                } else {
                    foreach my $subdevice_name (keys %{$device}) {
                        my $subdevice = $device->{$subdevice_name};
                        next unless ref $subdevice eq 'HASH';
                        push @storages,
                            _getStorage($subdevice, $subdevice_name, $bus_name)
                            if _isStorage($subdevice);
                    }
                }

            }
        }
    }

    return @storages;
}

sub _isStorage {
    my ($device) = @_;

    return 
        ($device->{'BSD Name'} && $device->{'BSD Name'} =~ /^disk\d+$/) || 
        ($device->{'Protocol'} && $device->{'Socket Type'});
}

sub _getStorage {
    my ($device, $device_name, $bus_name) = @_;

    my $storage = {
        NAME         => $device_name,
        MANUFACTURER => getCanonicalManufacturer($device_name),
        TYPE         => $bus_name eq 'FireWire' ? '1394' : $bus_name,
        SERIAL       => $device->{'Serial Number'},
        FIRMWARE     => $device->{'Revision'},
        MODEL        => $device->{'Model'},
        DISKSIZE     => $device->{'Capacity'}
    };

    if (!$device->{'Protocol'}) {
        $storage->{DESCRIPTION} = 'Disk drive';
    } elsif ($device->{'Protocol'} eq 'ATAPI' || $device->{'Drive Type'}) {
        $storage->{DESCRIPTION} = 'CD-ROM Drive';
    }

    if ($storage->{DISKSIZE}) {
        #e.g: Capacity: 320,07 GB (320 072 933 376 bytes)
        $storage->{DISKSIZE} =~ s/\s*\(.*//;
        $storage->{DISKSIZE} =~ s/ GB//;
        $storage->{DISKSIZE} =~ s/,/./;
        $storage->{DISKSIZE} = int($storage->{DISKSIZE} * 1024);
    }

    if ($storage->{MODEL}) {
        $storage->{MODEL} =~ s/\s*$storage->{MANUFACTURER}\s*//i;
    }

    return $storage;
}

1;
