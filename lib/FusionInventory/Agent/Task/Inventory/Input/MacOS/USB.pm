package FusionInventory::Agent::Task::Inventory::Input::MacOS::USB;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $device (_getDevices(command => 'ioreg -l', logger => $logger)) {
        $inventory->addEntry(
            section => 'USBDEVICES',
            entry   => $device,
            noDuplicated => 1
        );
    }
}

sub _getDevices {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $state = 0;
    my @devices;  
    my $device;   

    while (my $line = <$handle>) {
        $line =~ s/^[\|\s]*//;     
        $state = 1 if $line =~ /<class IOUSBDevice,/;
        $state = 2 if $state == 1 && $line =~ /^\{/;

        if ($state == 2 && $line =~ /^\}/) {
            $state = 0;   
            push @devices, {
                VENDORID  => sprintf("%x", $device->{'idVendor'}),
                PRODUCTID => sprintf("%x", $device->{'idProduct'}),
                SERIAL    => $device->{'USB Serial Number'},
                NAME      => $device->{'USB Product Name'},
                CLASS     => $device->{'bDeviceClass'},
                SUBCLASS  => $device->{'bDeviceSubClass'}
            } if keys %$device;
            $device = {};
        } 

        if ($state == 2) {
            if (/(.*?)\s=\s(.*)/) {                                                                                                        
                my $key = $1;
                my $val = $2;

                $key =~ s/"(.*)"/$1/;
                $val =~ s/"(.*)"/$1/;

                $device->{$key}=$val;
            } 
        } 
    } 
    close $handle;

    return @devices;
}

1;
