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



    my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2") or die "WMI connection failed.\n";
    my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_Process", "WQL",
            wbemFlagReturnImmediately | wbemFlagForwardOnly);

    foreach my $objItem (in $colItems) {
    
        my $cmdLine = $objItem->{CommandLine};
    
        if ($cmdLine =~ /\\Explorer\.exe/i) {
            my $name = Variant (VT_BYREF | VT_BSTR, '');
            my $domain = Variant (VT_BYREF | VT_BSTR, '');
    
            $objItem->GetOwner($name, $domain);
    
    
           if (Win32::GetOSName() ne 'Win7') {
               $name = encode("UTF-8", $name);
               $domain = encode("UTF-8", $domain);
           }
            $inventory->addUser({ LOGIN => $name, DOMAIN => $domain });
        }
    
    }
    

    foreach (`query session`) {
        if (/^(\s|)\S+\s+(\S+)\s+\d+/) {
            $inventory->addUser({ LOGIN => $2 });
        }
    }
}
1;
