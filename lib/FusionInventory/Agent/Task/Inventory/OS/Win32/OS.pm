package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};



    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_OperatingSystem' ) ) )
    {

        my $osname = $Properties->{Caption};
        my $osversion = $Properties->{Version};
        my $serialnumber = $Properties->{SerialNumber};




        $inventory->setHardware({

                OSNAME =>  encode('UTF-8', $osname),
                OSVERSION =>  encode('UTF-8', $osversion),
                WINPRODKEY => encode('UTF-8', $serialnumber),

                });

    }




    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_ComputerSystem' ) ) )
    {

        my $workgroup = $Properties->{Workgroup};
        my $userdomain;
        my $userid;
        my @tmp = split(/\\/, $Properties->{UserName});
        $userdomain = $tmp[0];
        $userid = $tmp[1]; # Deprecated, will be ignored by $inventory
        my $winowner = encode("UTF-8", $Properties->{PrimaryOwnerName});

        $inventory->setHardware({

                USERDOMAIN => encode('UTF-8', $userdomain),
                USERDID => encode('UTF-8', $userid),
                WORKGROUP => encode('UTF-8', $workgroup),
                WINOWNER => $winowner,

                });

    }
}
1;
