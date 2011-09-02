package FusionInventory::Agent::Task::Inventory::Input::Win32::Chassis;

use strict;
use warnings;

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

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $WMIService = Win32::OLE->GetObject(
        'winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\cimv2'
    ) or die "WMI connection failed: " . Win32::OLE->LastError();

    my $enclosures = $WMIService->ExecQuery('SELECT * FROM Win32_SystemEnclosure');
    my ($enclosure) = (in $enclosures);

    return unless $enclosure;

    my $chassisTypeId = $enclosure->ChassisTypes->[0];
    $inventory->setBios({
        TYPE => $chassisType[$chassisTypeId]
    });
}

1;
