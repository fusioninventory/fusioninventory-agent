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

    # system profiler data structure:
    # bus
    # └── controller
    #     ├── device
    #     │   ├── subdevice
    #     │   │   └── key:value
    #     │   └── key:value
    #     └── key:value

    my @storages;
    my @busNames = ('ATA', 'SERIAL-ATA', 'USB', 'FireWire', 'Fibre Channel');
    foreach my $busName (@busNames) {
        my $bus = $infos->{$busName};
        next unless $bus;
        foreach my $controllerName (keys %{$bus}) {
            my $controller = $bus->{$controllerName};
            foreach my $deviceName (keys %{$controller}) {
                my $device = $controller->{$deviceName};
                next unless ref $device eq 'HASH';
                if (_isStorage($device)) {
                    push @storages,
                        _getStorage($device, $deviceName, $busName);
                } else {
                    foreach my $subdeviceName (keys %{$device}) {
                        my $subdevice = $device->{$subdeviceName};
                        next unless ref $subdevice eq 'HASH';
                        push @storages,
                            _getStorage($subdevice, $subdeviceName, $busName)
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
        $storage->{DISKSIZE} =~ s/,/./;

        if ($storage->{DISKSIZE} =~ s/\s*TB//) {
            $storage->{DISKSIZE} = int($storage->{DISKSIZE} * 1000 * 1000);
        } elsif ($storage->{DISKSIZE} =~ s/\s+GB$//) {
            $storage->{DISKSIZE} = int($storage->{DISKSIZE} * 1000 * 1000);
        }
    }

    if ($storage->{MODEL}) {
        $storage->{MODEL} =~ s/\s*$storage->{MANUFACTURER}\s*//i;
    }

    return $storage;
}

1;
