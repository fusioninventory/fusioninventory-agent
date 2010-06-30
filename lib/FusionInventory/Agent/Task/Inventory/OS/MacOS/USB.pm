package FusionInventory::Agent::Task::Inventory::OS::MacOS::USB;

use strict;
use warnings;

#          {
#            'IOGeneralInterest' => 'IOCommand is not serializable',
#            'USB Address' => '3',
#            'Requested Power' => '10',
#            'idProduct' => '545',
#            'bMaxPacketSize0' => '8',
#            'USB Vendor Name' => 'Apple, Inc',
#            'sessionID' => '1472072547',
#            'bNumConfigurations' => '1',
#            'bDeviceProtocol' => '0',
#            'Bus Power Available' => '50',
#            'PortUsingExtraPowerForWake' => '0',
#            'Device Speed' => '0',
#            'IOCFPlugInTypes' => '{9dc7b780-9ec0-11d4-a54f-000a27052861"="IOUSBFamily.kext/Contents/PlugIns/IOUSBLib.bundle}',
#            'iProduct' => '2',
#            'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
#            'USB Product Name' => 'Apple Keyboard',
#            'bDeviceSubClass' => '0',
#            'bDeviceClass' => '0',
#            'PortNum' => '2',
#            'non-removable' => 'yes',
#            'locationID' => '18446744073611116544',
#            'bcdDevice' => '105',
#            'Low Power Displayed' => 'No',
#            'iManufacturer' => '1',
#            'iSerialNumber' => '0',
#            'idVendor' => '1452'
#          },
#          {
#            'IOGeneralInterest' => 'IOCommand is not serializable',
#            'USB Address' => '4',
#            'Requested Power' => '50',
#            'idProduct' => '49174',
#            'bMaxPacketSize0' => '8',
#            'USB Vendor Name' => 'Logitech',
#            'sessionID' => '1586211098',
#            'bNumConfigurations' => '1',
#            'bDeviceProtocol' => '0',
#            'Bus Power Available' => '50',
#            'PortUsingExtraPowerForWake' => '0',
#            'Device Speed' => '0',
#            'IOCFPlugInTypes' => '{9dc7b780-9ec0-11d4-a54f-000a27052861"="IOUSBFamily.kext/Contents/PlugIns/IOUSBLib.bundle}',
#            'iProduct' => '2',
#            'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
#            'USB Product Name' => 'Optical USB Mouse',
#            'bDeviceSubClass' => '0',
#            'bDeviceClass' => '0',
#            'PortNum' => '3',
#            'bcdDevice' => '832',
#            'locationID' => '18446744073611182080',
#            'Low Power Displayed' => 'No',
#            'iManufacturer' => '1',
#            'iSerialNumber' => '0',
#            'idVendor' => '1133'
#          }


sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};


    my $state = 0;
#IOUSBDevice  
    my @devices;  
    my $device;   
    foreach (`ioreg -l`) {
        s/^[\|\s]*//;     
        $state = 1 if /<class IOUSBDevice/; 
        $state = 2 if $state == 1 && /^\{/;
        if ($state == 2 && /^\}/) {
            $state = 0;   
            push @devices, $device if keys %$device;
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

    foreach (@devices) {
        $inventory->addUSBDevice({

                VENDORID => sprintf("%x", $_->{'idVendor'}),
                PRODUCTID => sprintf("%x", $_->{'idProduct'}),
                SERIAL => $_->{'USB Serial Number'},
                NAME => $_->{'USB Product Name'},
                CLASS => $_->{'bDeviceClass'},
                SUBCLASS => $_->{'bDeviceSubClass'}

            });
    }
}

1;
