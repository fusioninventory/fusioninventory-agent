package FusionInventory::Agent::Task::Inventory::Input::Win32::Users;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use English qw(-no_match_vars);
use Win32::OLE;
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);


use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $user (_getLocalUsers(logger => $logger)) {
        $inventory->addEntry(
            section => 'LOCALUSERS',
            entry   => $user
        );
    }

    foreach my $user (_getLoggedUsers(logger => $logger)) {
        $inventory->addEntry(
            section => 'USERS',
            entry   => $user
        );
    }

    $inventory->setHardware(
        _getLastUser(logger => $logger)
    );
}

sub _getLocalUsers {

    my @users;
    foreach my $object (getWmiObjects(
        class      => 'Win32_UserAccount',
        properties => [ qw/LocalAccount Name SID Disabled Lockout/ ]
    )) {
        next unless $object->{LocalAccount};
        next if $object->{Disabled};
        next if $object->{Lockout};

        push @users, {
            NAME => $object->{Name},
            ID   => $object->{SID},
        };
    }

    return @users;
}

sub _getLoggedUsers {

    my $WMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2")
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my $processes = $WMIService->ExecQuery(
        "SELECT * FROM Win32_Process", "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly ## no critic (ProhibitBitwise)
    );

    my @users;
    my $seen;

    foreach my $process (in $processes) {
        next unless
            $process->{ExecutablePath} &&
            $process->{ExecutablePath} =~ /\\Explorer\.exe$/i;

        ## no critic (ProhibitBitwise)
        my $name = Variant(VT_BYREF | VT_BSTR, '');
        my $domain = Variant(VT_BYREF | VT_BSTR, '');

        $process->GetOwner($name, $domain);

        my $user = {
            LOGIN  => $name->Get(),
            DOMAIN => $domain->Get()
        };

        utf8::upgrade($user->{LOGIN});
        utf8::upgrade($user->{DOMAIN});

        next if $seen->{$user->{LOGIN}}++;
    }

    return @users;
}

sub _getLastUser {

    my $machKey = $Registry->Open('LMachine', {
        Access => KEY_READ
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $user;

    foreach my $key (
        "SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon/DefaultUserName",
        "SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/LastLoggedOnUser"
    ) {
        $user = encodeFromRegistry($machKey->{$key});
        next unless $user;
        $user =~ s,.*\\,,;
    }

    return $user;
}

1;
