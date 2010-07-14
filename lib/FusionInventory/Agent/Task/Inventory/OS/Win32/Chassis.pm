package FusionInventory::Agent::Task::Inventory::OS::Win32::Chassis;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use Win32::OLE qw(in);

my @chassisType = (
        'Unknown',
        'Other',
        'Unknown',
        'Desktop',
        'Low Profile Desktop',
        'Pizza Box',
        'Mini Tower',
        'Tower',
        'Portable',
        'Laptop',
        'Notebook',
        'Hand Held',
        'Docking Station',
        'All in One',
        'Sub Notebook',
        'Space-Saving',
        'Lunch Box',
        'Main System Chassis',
        'Expansion Chassis',
        'SubChassis',
        'Bus Expansion Chassis',
        'Peripheral Chassis',
        'Storage Chassis',
        'Rack Mount Chassis',
        'Sealed-Case PC'
        );


        sub doInventory {
            my $params = shift;
            my $inventory = $params->{inventory};

            my $strComputer = '.';

            my $objWMIService = Win32::OLE->GetObject('winmgmts:' . '{impersonationLevel=impersonate}!\\\\' . $strComputer . '\\root\\cimv2');

            my $tmp = $objWMIService->ExecQuery('SELECT * FROM Win32_SystemEnclosure');
            my ($systemEnclosure) = (in $tmp);

            my $chassisTypeId = $systemEnclosure->ChassisTypes->[0];
            $inventory->setBios({
                TYPE => $chassisType[$chassisTypeId]
                    });
        }

1;
