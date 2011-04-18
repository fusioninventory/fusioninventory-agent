package FusionInventory::Agent::Task::Inventory::OS::Win32::User;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use English qw(-no_match_vars);
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $WMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2")
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my $processes = $WMIService->ExecQuery(
        "SELECT * FROM Win32_Process", "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly
    );

    foreach my $process (in $processes) {
    
        my $cmdLine = $process->{CommandLine};

        next unless $cmdLine;
 
        if ($cmdLine =~ /\\Explorer\.exe$/i) {
            my $name = Variant (VT_BYREF | VT_BSTR, '');
            my $domain = Variant (VT_BYREF | VT_BSTR, '');
    
            $process->GetOwner($name, $domain);
   
            $inventory->addUser({
                LOGIN => $name->Get(),
                DOMAIN => $domain->Get()
            });
        }
    }

    my $machKey = $Registry->Open('LMachine', {
        Access => KEY_READ
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    foreach (
        "SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon/DefaultUserName",
        "SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/LastLoggedOnUser"
    ) {
        my $lastloggeduser = encodeFromRegistry($machKey->{$_});
        next unless $lastloggeduser;
        $lastloggeduser =~ s,.*\\,,;
        $inventory->setHardware(
           LASTLOGGEDUSER => $lastloggeduser
        );
    }

}

1;
