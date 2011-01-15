package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers;
use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

my $vendors;
my $classes;

sub isInventoryEnabled {
    return can_run('lspci');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $datadir   = $params{datadir};

    _loadPciIds($logger, $datadir);

    foreach my $controller (_getExtentedControllers($logger)) {
        $inventory->addController($controller);
    }
}

sub _getExtentedControllers {
    my ($logger, $file) = @_;

    my @controllers = getControllersFromLspci(logger => $logger, file => $file);

    foreach my $controller (@controllers) {

        next unless $controller->{PCIID};

        my ($vendor_id, $device_id) = split (/:/, $controller->{PCIID});
        my $subdevice_id = $controller->{PCISUBSYSTEMID};

        if ($vendors->{$vendor_id}) {
            my $vendor = $vendors->{$vendor_id};
            $controller->{MANUFACTURER} = $vendor->{name};

            if ($vendor->{devices}->{$device_id}) {
                my $device = $vendor->{devices}->{$device_id};
                $controller->{CAPTION} =
                    $device->{name};

                $controller->{NAME} =
                    $subdevice_id && $device->{subdevices}->{$subdevice_id} ?

                    $device->{subdevices}->{$subdevice_id}->{name} :
                    $device->{name};
            }
        }

        next unless $controller->{PCICLASS};

        $controller->{PCICLASS} =~ /^(\S\S)(\S\S)$/x;
        my $class_id = $1;
        my $subclass_id = $2;

        if ($classes->{$class_id}) {
            my $class = $classes->{$class_id};

            $controller->{TYPE} = 
                $subclass_id && $class->{subclasses}->{$subclass_id} ?
                    $class->{subclasses}->{$subclass_id}->{name} :
                    $class->{name};
        }
    }

    return @controllers;
}

sub _loadPciIds {
    my ($logger, $sharedir) = @_;

    my $handle = getFileHandle(file => "$sharedir/pci.ids", logger => $logger);
    return unless $handle;

    my ($vendor_id, $device_id, $class_id);
    while (my $line = <$handle>) {
        next if $line =~ /^#/;

        if ($line =~ /^(\S{4}) \s+ (.*)/x) {
            # Vendor ID
            $vendor_id = $1;
            $vendors->{$vendor_id}->{name} = $2;
        } elsif ($line =~ /^\t (\S{4}) \s+ (.*)/x) {
            # Device ID
            $device_id = $1;
            $vendors->{$vendor_id}->{devices}->{$device_id}->{name} = $2;
        } elsif ($line =~ /^\t\t (\S{4}) \s+ (\S{4}) \s+ (.*)/x) {
            # Subdevice ID
            my $subdevice_id = "$1:$2";
            $vendors->{$vendor_id}->{devices}->{$device_id}->{subdevices}->{$subdevice_id}->{name} = $3;
        } elsif ($line =~ /^C \s+ (\S{2}) \s+ (.*)/x) {
            # Class ID
            $class_id = $1;
            $classes->{$class_id}->{name} = $2;
        } elsif ($line =~ /^\t (\S{2}) \s+ (.*)/x) {
            # SubClass ID
            my $subclass_id = $1;
            $classes->{$class_id}->{subclasses}->{$subclass_id}->{name} = $2;
        } 
    }
    close $handle;
}

1;
