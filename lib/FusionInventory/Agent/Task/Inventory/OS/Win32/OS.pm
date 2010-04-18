package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use FusionInventory::Agent::Task::Inventory::OS::Win32;
use strict;

sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

        foreach my $Properties
            (FusionInventory::Agent::Task::Inventory::OS::Win32::getWmiProperties('Win32_OperatingSystem',
qw/OSLanguage Caption Version SerialNumber/)) {

        $inventory->setHardware({

                WINLANG => $Properties->{OSLanguage},
                OSNAME => $Properties->{Caption},
                OSVERSION =>  $Properties->{Version},
                WINPRODKEY => $Properties->{SerialNumber},

                });

    }


        foreach my $Properties
            (FusionInventory::Agent::Task::Inventory::OS::Win32::getWmiProperties('Win32_ComputerSystem',
qw/Workgroup UserName PrimaryOwnerName/)) {


        my $workgroup = $Properties->{Workgroup};
        my $userdomain;
        my $userid;
        my @tmp = split(/\\/, $Properties->{UserName});
        $userdomain = $tmp[0];
        $userid = $tmp[1];
        my $winowner = $Properties->{PrimaryOwnerName};

        #$inventory->addUser({ LOGIN => encode('UTF-8', $Properties->{UserName}) });
        $inventory->addUser({ LOGIN => $userid });
        $inventory->setHardware({

                USERDOMAIN => $userdomain,
                WORKGROUP => $workgroup,
                WINOWNER => $winowner,

                });

    }


    foreach (`query session`) {
        if (/^(\s|)\S+\s+(\S+)\s+\d+/) {
            $inventory->addUser({ LOGIN => $2 });
        }
    }
}
1;
