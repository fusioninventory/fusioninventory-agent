package FusionInventory::Agent::Task::Inventory::Win32::Users;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use English qw(-no_match_vars);
use Win32::OLE qw(in);
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{user};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    if (!$params{no_category}->{local_user}) {
        foreach my $user (_getLocalUsers(logger => $logger)) {
            $inventory->addEntry(
                section => 'LOCAL_USERS',
                entry   => $user
            );
        }
    }

    if (!$params{no_category}->{local_group}) {
        foreach my $group (_getLocalGroups(logger => $logger)) {
            $inventory->addEntry(
                section => 'LOCAL_GROUPS',
                entry   => $group
            );
        }
    }

    foreach my $user (_getLoggedUsers(logger => $logger)) {
        $inventory->addEntry(
            section => 'USERS',
            entry   => $user
        );
    }

    $inventory->setHardware({
        LASTLOGGEDUSER => _getLastUser(logger => $logger)
    });
}

sub _getLocalUsers {

    my $WMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2")
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my $query =
        "SELECT * FROM Win32_UserAccount " .
        "WHERE LocalAccount='True' AND Disabled='False' and Lockout='False'";

    my @users;

    foreach my $object (in $WMIService->ExecQuery($query)) {
        my $user = {
            NAME => $object->{Name},
            ID   => $object->{SID},
        };
        utf8::upgrade($user->{NAME});
        push @users, $user;
    }

    return @users;
}

sub _getLocalGroups {

    my $WMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2")
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my $query =
        "SELECT * FROM Win32_Group " .
        "WHERE LocalAccount='True'";

    my @groups;

    foreach my $object (in $WMIService->ExecQuery($query)) {
        my $group = {
            NAME => $object->{Name},
            ID   => $object->{SID},
        };
        utf8::upgrade($group->{NAME});
        push @groups, $group;
    }

    return @groups;
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

        push @users, $user;
    }

    return @users;
}

sub _getLastUser {

    # ensure native registry access, not the 32 bit view
    my $flags = is64bit() ? KEY_READ | KEY_WOW64_64 : KEY_READ;

    my $machKey = $Registry->Open('LMachine', {
        Access => $flags
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $user =
        encodeFromRegistry($machKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/LastLoggedOnUser"}) ||
        encodeFromRegistry($machKey->{"SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon/DefaultUserName"});
    return unless $user;

    $user =~ s,.*\\,,;
    return $user;
}

1;
