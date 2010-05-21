package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use strict;

use Win32::OLE::Variant;

use Encode qw(encode);

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;



sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

        foreach my $Properties
            (getWmiProperties('Win32_OperatingSystem',
qw/OSLanguage Caption Version SerialNumber Organization RegisteredUser CSDVersion/)) {

        $inventory->setHardware({

                WINLANG => $Properties->{OSLanguage},
                OSNAME => $Properties->{Caption},
                OSVERSION =>  $Properties->{Version},
                WINPRODKEY => $Properties->{SerialNumber},
                WINCOMPANY => $Properties->{Organization},
                WINOWNER => $Properties->{RegistredUser},
                OSCOMMENTS => $Properties->{CSDVersion},

                });

    }


        foreach my $Properties
            (getWmiProperties('Win32_ComputerSystem',
qw/Workgroup UserName PrimaryOwnerName/)) {


        my $workgroup = $Properties->{Workgroup};
        my $userdomain;
#        my $userid;
#        my @tmp = split(/\\/, $Properties->{UserName});
#        $userdomain = $tmp[0];
#        $userid = $tmp[1];
        my $winowner = $Properties->{PrimaryOwnerName};

        #$inventory->addUser({ LOGIN => encode('UTF-8', $Properties->{UserName}) });
        $inventory->setHardware({

                USERDOMAIN => $userdomain,
                WORKGROUP => $workgroup,
                WINOWNER => $winowner,

                });

    }

}
1;
