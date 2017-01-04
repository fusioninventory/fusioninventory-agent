package FusionInventory::Agent::Task::Inventory::Win32::Users;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

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

    my $query =
        "SELECT * FROM Win32_UserAccount " .
        "WHERE LocalAccount='True' AND Disabled='False' and Lockout='False'";

    my @users;

    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => [ $query ],
        properties => [ qw/Name SID/ ])
    ) {
        my $user = {
            NAME => $object->{Name},
            ID   => $object->{SID},
        };
        push @users, $user;
    }

    return @users;
}

sub _getLocalGroups {

    my $query =
        "SELECT * FROM Win32_Group " .
        "WHERE LocalAccount='True'";

    my @groups;

    foreach my $object (getWMIObjects(
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => [ $query ],
        properties => [ qw/Name SID/ ])
    ) {
        my $group = {
            NAME => $object->{Name},
            ID   => $object->{SID},
        };
        push @groups, $group;
    }

    return @groups;
}

sub _getLoggedUsers {

    my @query = (
        "SELECT * FROM Win32_Process".
        " WHERE ExecutablePath IS NOT NULL" .
        " AND ExecutablePath LIKE '%\\\\Explorer\.exe'", "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly ## no critic (ProhibitBitwise)
    );

    my @users;
    my $seen;

    foreach my $user (getWMIObjects(
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => \@query,
        method     => 'GetOwner',
        params     => [ 'name', 'domain' ],
        name       => [ 'string', '' ],
        domain     => [ 'string', '' ],
        binds      => {
            name    => 'LOGIN',
            domain  => 'DOMAIN'
        })
    ) {
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
