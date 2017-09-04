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
use Storable 'dclone';

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

    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};

    if (!$params{no_category}->{local_user}) {
        $logger->debug2('_getLocalUsers() now') if $logger;
        foreach my $user (_getLocalUsers(logger => $logger, %$wmiParams)) {
            $inventory->addEntry(
                section => 'LOCAL_USERS',
                entry   => $user
            );
        }
        $logger->debug2('_getLocalUsers() finished') if $logger;
    }

    if (!$params{no_category}->{local_group}) {
        $logger->debug2('_getLocalGroups() now') if $logger;
        foreach my $group (_getLocalGroups(logger => $logger, %$wmiParams)) {
            $inventory->addEntry(
                section => 'LOCAL_GROUPS',
                entry   => $group
            );
        }
        $logger->debug2('_getLocalGroups() finished') if $logger;
    }

    $logger->debug2('_getLoggedUsers() now') if $logger;
    foreach my $user (_getLoggedUsers(logger => $logger, %$wmiParams)) {
        $inventory->addEntry(
            section => 'USERS',
            entry   => $user
        );
    }
    $logger->debug2('_getLoggedUsers() finished') if $logger;

    $logger->debug2('_getLastUser() now') if $logger;
    $inventory->setHardware({
        LASTLOGGEDUSER => _getLastUser(logger => $logger, %$wmiParams) || ''
    });
    $logger->debug2('_getLastUser() finished') if $logger;
}

sub _getLocalUsers {
    my (%params) = @_;

    my $query =
        "SELECT * FROM Win32_UserAccount " .
        "WHERE LocalAccount='True' AND Disabled='False' and Lockout='False'";

    $params{WMIService}->{root} = "root\\cimv2" if $params{WMIService};
    my @users;
    foreach my $object (getWMIObjects(
        %params,
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => [ $query ],
        properties => [ qw/Name SID/ ]
    )) {
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
    my (%params) = @_;

    my $query =
        "SELECT * FROM Win32_Group " .
        "WHERE LocalAccount='True'";

    $params{WMIService}->{root} = "root\\cimv2" if $params{WMIService};
    my @groups;
    foreach my $object (getWMIObjects(
        %params,
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => [ $query ],
        properties => [ qw/Name SID/ ]
    )) {
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
    my (%params) = @_;

    my $query = [
        "SELECT * FROM Win32_Process".
            " WHERE ExecutablePath IS NOT NULL" .
            " AND ExecutablePath LIKE '%\\\\Explorer\.exe'",
        "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly ## no critic (ProhibitBitwise)
    ];

    $params{WMIService}->{root} = "root\\cimv2" if $params{WMIService};

    my @users;
    my $seen;
    my @objects = getWMIObjects(
        %params,
        moniker    => 'winmgmts:\\\\.\\root\\CIMV2',
        query      => $query,
        method     => 'GetOwner',
        params     => [ 'name', 'domain' ],
        name       => [ 'string', '' ],
        domain     => [ 'string', '' ],
        binds      => {
            name    => 'LOGIN',
            domain  => 'DOMAIN'
        }
    );
    foreach my $user ( @objects ) {
        next if $seen->{$user->{LOGIN}}++;
        push @users, $user;
    }

    return @users;
}

sub _getLastUser {
    my (%params) = @_;

    my @paths = (
        'SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/LastLoggedOnUser',
        'SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon/DefaultUserName'
    );
    my $user;
    if ($params{WMIService}) {
        $user = _getLastUserFromRemoteRegistry(
            %params,
            path => \@paths
        );
    } else {
        $user = _getLastUserFromLocalRegistry(
            path => \@paths
        )
    }
    return unless $user;

    $user =~ s,.*\\,,;
    return $user;
}

sub _getLastUserFromRemoteRegistry {
    my (%params) = @_;

    my $user = encodeFromRegistry(
        getRegistryValueFromWMI(
            %params,
            path => 'HKEY_LOCAL_MACHINE/' . $params{path}->[0]
        )
    ) || encodeFromRegistry(
        getRegistryValueFromWMI(
            %params,
            path => 'HKEY_LOCAL_MACHINE/' . $params{path}->[1]
        )
    );
    return $user;
}

sub _getLastUserFromLocalRegistry {
    my (%params) = @_;

    # ensure native registry access, not the 32 bit view
    my $flags = is64bit() ? KEY_READ | KEY_WOW64_64 : KEY_READ;

    my $machKey = $Registry->Open('LMachine', {
        Access => $flags
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $user =
        encodeFromRegistry($machKey->{$params{path}->[0]}) ||
        encodeFromRegistry($machKey->{$params{path}->[1]});
    return $user;
}

1;
