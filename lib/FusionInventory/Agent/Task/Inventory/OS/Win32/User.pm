package FusionInventory::Agent::Task::Inventory::OS::Win32::User;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use Carp;
use Encode qw(encode);
use English qw(-no_match_vars);
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2") or die "WMI connection failed.\n";
    my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_Process", "WQL",
            wbemFlagReturnImmediately | wbemFlagForwardOnly);

    foreach my $objItem (in $colItems) {
    
        my $cmdLine = $objItem->{CommandLine};

        next unless $cmdLine;
 
        if ($cmdLine =~ /\\Explorer\.exe$/i) {
            my $name = Variant (VT_BYREF | VT_BSTR, '');
            my $domain = Variant (VT_BYREF | VT_BSTR, '');
    
            $objItem->GetOwner($name, $domain);
   
            $inventory->addUser({ LOGIN => $name->Get(), DOMAIN => $domain->Get() });
        }
    
    }

    my $machKey = $Registry->Open('LMachine', {
        Access => KEY_READ
    }) or croak "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    foreach (
        "SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon/DefaultUserName",
        "SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/LastLoggedOnUser"
    ) {
        my $lastloggeduser=encodeFromRegistry($machKey->{$_});
        if ($lastloggeduser) {
            $lastloggeduser =~ s,.*\\,,;
            $inventory->setHardware({
               LASTLOGGEDUSER => $lastloggeduser
            });
        }
    }


}
1;
