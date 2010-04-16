package FusionInventory::Agent::Task::Inventory::OS::Win32::Inputs;
# Had never been tested.
use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

my %mouseInterface = (

1 =>  'Other',
2 => 'Unknown',
3 => 'Serial',
4 => 'PS/2',
5 => 'Infrared',
6 => 'HP-HIL',
7 => 'Bus Mouse',
8 => 'ADB (Apple Desktop Bus)',
160 => 'Bus Mouse DB-9',
161 => 'Bus Mouse Micro-DIN',
162 => 'USB',

);


sub isInventoryEnabled {1}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }


    my @inputs;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_Keyboard' ) ) )
    {


        push @inputs, {

            NAME => encode('UTF-8', $Properties->{Name}),
            CAPTION => encode('UTF-8', $Properties->{Caption}),
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            DESCRIPTION => encode('UTF-8', $Properties->{Description}),
            LAYOUT => encode('UTF-8', $Properties->{Layout}),

        };

    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_PointingDevice' ) ) )
    {


        push @inputs, {

            NAME => encode('UTF-8', $Properties->{Name}),
            CAPTION => encode('UTF-8', $Properties->{Caption}),
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            DESCRIPTION => encode('UTF-8', $Properties->{Description}),
            POINTINGTYPE => encode('UTF-8', $Properties->{PointingType}),
            INTERFACE => encode('UTF-8', 
$mouseInterface{$Properties->{DeviceInterface}}),

        };

    }


    foreach (@inputs) {
        $inventory->addInput($_);
    }

}
1;
