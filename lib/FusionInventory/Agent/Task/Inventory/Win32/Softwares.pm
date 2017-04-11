package FusionInventory::Agent::Task::Inventory::Win32::Softwares;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);
use File::Basename;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Win32::Constants;

my $seen = {};

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{software};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $is64bit = is64bit();


    if ($is64bit) {

        # I don't know why but on Vista 32bit, KEY_WOW64_64 is able to read
        # 32bit entries. This is not the case on Win2003 and if I correctly
        # understand MSDN, this sounds very odd

        my $machKey64 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_64 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
        my $softwaresKey64 =
            $machKey64->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};
        my $softwares64 =_getSoftwaresList(
            softwares => $softwaresKey64,
            is64bit   => 1,
        );
        foreach my $software (@$softwares64) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey64,
            inventory => $inventory,
            is64bit   => 1
        );

        if ($params{scan_profiles}) {
            _loadUserSoftware(
                inventory => $inventory,
                is64bit   => 1,
                logger    => $logger
            );
        } else {
            $logger->warning(
                "'scan-profiles' configuration parameter disabled, " .
                "ignoring software in user profiles"
            );
        }

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
        my $softwaresKey32 =
            $machKey32->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};
        my $softwares32 = _getSoftwaresList(
            softwares => $softwaresKey32,
            is64bit   => 0,
            logger    => $logger,
        );
        foreach my $software (@$softwares32) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey32,
            inventory => $inventory,
            is64bit   => 0
        );
        _loadUserSoftware(
            inventory => $inventory,
            is64bit   => 0,
            logger    => $logger
        ) if $params{scan_profiles};
    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
        my $softwaresKey =
            $machKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};
        my $softwares = _getSoftwaresList(
            softwares => $softwaresKey,
            is64bit   => 0,
        );
        foreach my $software (@$softwares) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey,
            inventory => $inventory,
            is64bit   => 0
        );
        _loadUserSoftware(
            inventory => $inventory,
            is64bit   => 0,
            logger    => $logger
        ) if $params{scan_profiles};

    }

    my $hotfixes = _getHotfixesList(is64bit => $is64bit);
    foreach my $hotfix (@$hotfixes) {
        # skip fixes already found in generic software list,
        # without checking version information
        next if $seen->{$hotfix->{NAME}};
        _addSoftware(inventory => $inventory, entry => $hotfix);
    }

}

sub _loadUserSoftware {
    my (%params) = @_;

    _loadUserSoftwareFromNtuserDatFiles(%params);
    my $userList = getUsersFromRegistry(%params);
    _loadUserSoftwareFromHKey_Users($userList, %params);
}

sub _loadUserSoftwareFromNtuserDatFiles {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $is64bit   = $params{is64bit};
    my $logger    = $params{logger};

    my $machKey = $Registry->Open('LMachine', {
        Access => KEY_READ
    }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

    my $profileList =
        $machKey->{"SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProfileList"};

    return unless $profileList;

    $Registry->AllowLoad(1);

    foreach my $profileName (keys %$profileList) {
        # we're only interested in subkeys
        next unless $profileName =~ m{/$};
        next unless length($profileName) > 10;

        my $profilePath = $profileList->{$profileName}{'/ProfileImagePath'};
        my $sid = $profileList->{$profileName}{'/Sid'};

        next unless $sid;
        next unless $profilePath;

        $profilePath =~ s/%SystemDrive%/$ENV{SYSTEMDRIVE}/i;

        my $user = basename($profilePath);
        ## no critic (ProhibitBitwise)
        my $userKey = $is64bit                                                                   ?
            $Registry->Load( $profilePath.'\ntuser.dat', { Access => KEY_READ | KEY_WOW64_64 } ) :
            $Registry->Load( $profilePath.'\ntuser.dat', { Access => KEY_READ } );

        my $softwaresKey =
            $userKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        my $softwares = _getSoftwaresList(
            softwares => $softwaresKey,
            is64bit   => $is64bit,
            userid    => $sid,
            username  => $user
        );
        my $nbUsers = 0;
        if ($softwares) {
            $nbUsers = scalar(@$softwares);
        }
        $logger->debug2('_loadUserSoftwareFromNtuserDatFiles() : add of ' . $nbUsers . ' softwares in inventory');
        foreach my $software (@$softwares) {
            _addSoftware(inventory => $inventory, entry => $software);
        }

    }
    $Registry->AllowLoad(0);
}

sub _loadUserSoftwareFromHKey_Users {
    my ($userList, %params) = @_;

    return unless $userList;

    my $inventory = $params{inventory};
    my $is64bit   = $params{is64bit};
    my $logger    = $params{logger};

    my $profileList = $Registry->Open('Users', {
            Access => KEY_READ
        }) or $logger->error("Can't open HKEY_USERS key: $EXTENDED_OS_ERROR");
    return unless $profileList;

    $Registry->AllowLoad(1);
    
    foreach my $profileName (keys %$profileList) {
        # we're only interested in subkeys
        next unless $profileName =~ m{/$};
        next unless length($profileName) > 10;

        my $userName = '';
        if ($userList->{$profileName}) {
            $userName = $userList->{$profileName};
        } else {
            next;
        }
        my $softwaresKey = $profileList->{$profileName}{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        my $softwares = _getSoftwaresList(
            softwares => $softwaresKey,
            is64bit   => $is64bit,
            userid    => $profileName,
            username  => $userName
        );
        my $nbUsers = 0;
        if ($softwares) {
            $nbUsers = scalar(@$softwares);
        }
        $logger->debug2('_loadUserSoftwareFromHKey_Users() : add of ' . $nbUsers . ' softwares in inventory');
        foreach my $software (@$softwares) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
    }
    $Registry->AllowLoad(0);

}

sub _dateFormat {
    my ($date) = @_;

    ## no critic (ExplicitReturnUndef)
    return undef unless $date;

    if ($date =~ /^(\d{4})(\d{1})(\d{2})$/) {
        return "$3/0$2/$1";
    }

    if ($date =~ /^(\d{4})(\d{2})(\d{2})$/) {
        return "$3/$2/$1";
    }

    # Re-order "M/D/YYYY" as "DD/MM/YYYY"
    if ($date =~ /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/) {
        return sprintf("%02d/%02d/%04d", $2, $1, $3);
    }

    return undef;
}

sub _keyLastWriteDateString {
    my ($key) = @_;

    return unless ($OSNAME eq 'MSWin32');

    return unless (ref($key) eq "Win32::TieRegistry");

    my @lastWrite = FileTimeToSystemTime($key->Information("LastWrite"));

    return unless (@lastWrite > 3);

    return sprintf("%04s%02s%02s",$lastWrite[0],$lastWrite[1],$lastWrite[3]);
}

sub _getSoftwaresList {
    my (%params) = @_;

    my $softwares = $params{softwares};

    my @list;

    return unless $softwares;

    foreach my $rawGuid (keys %$softwares) {
        # skip variables
        next if $rawGuid =~ m{^/};

        # only keep subkeys with more than 1 value
        my $data = $softwares->{$rawGuid};
        next unless keys %$data > 1;

        my $guid = $rawGuid;
        $guid =~ s/\/$//; # drop the tailing /

        my $software = {
            FROM             => "registry",
            NAME             => encodeFromRegistry($data->{'/DisplayName'}) ||
                                encodeFromRegistry($guid), # folder name
            COMMENTS         => encodeFromRegistry($data->{'/Comments'}),
            HELPLINK         => encodeFromRegistry($data->{'/HelpLink'}),
            RELEASE_TYPE     => encodeFromRegistry($data->{'/ReleaseType'}),
            VERSION          => encodeFromRegistry($data->{'/DisplayVersion'}),
            PUBLISHER        => encodeFromRegistry($data->{'/Publisher'}),
            URL_INFO_ABOUT   => encodeFromRegistry($data->{'/URLInfoAbout'}),
            UNINSTALL_STRING => encodeFromRegistry($data->{'/UninstallString'}),
            INSTALLDATE      => _dateFormat($data->{'/InstallDate'}),
            VERSION_MINOR    => hex2dec($data->{'/MinorVersion'}),
            VERSION_MAJOR    => hex2dec($data->{'/MajorVersion'}),
            NO_REMOVE        => hex2dec($data->{'/NoRemove'}),
            ARCH             => $params{is64bit} ? 'x86_64' : 'i586',
            GUID             => $guid,
            USERNAME         => $params{username},
            USERID           => $params{userid},
            SYSTEM_CATEGORY  => $data->{'/SystemComponent'} && hex2dec($data->{'/SystemComponent'}) ?
                CATEGORY_SYSTEM_COMPONENT : CATEGORY_APPLICATION
        };

        # Workaround for #415
        $software->{VERSION} =~ s/[\000-\037].*// if $software->{VERSION};

        # Set install date to last registry key update time
        if (!defined($software->{INSTALLDATE})) {
            $software->{INSTALLDATE} = _dateFormat(_keyLastWriteDateString($data));
        }

        push @list, $software;
    }

    return \@list;
}

sub _getHotfixesList {
    my (%params) = @_;

    my $list;

    foreach my $object (getWMIObjects(
        class      => 'Win32_QuickFixEngineering',
        properties => [ qw/HotFixID Description InstalledOn/  ]
    )) {

        my $releaseType;
        if ($object->{Description} && $object->{Description} =~ /^(Security Update|Hotfix|Update)/) {
            $releaseType = $1;
        }
        my $systemCategory = !$releaseType       ? CATEGORY_UPDATE :
            ($releaseType =~ /^Security Update/) ? CATEGORY_SECURITY_UPDATE :
            $releaseType =~ /^Hotfix/            ? CATEGORY_HOTFIX :
                                                   CATEGORY_UPDATE ;

        next unless $object->{HotFixID} =~ /KB(\d{4,10})/i;
        push @$list, {
            NAME         => $object->{HotFixID},
            COMMENTS     => $object->{Description},
            INSTALLDATE  => _dateFormat($object->{InstalledOn}),
            FROM         => "WMI",
            RELEASE_TYPE => $releaseType,
            ARCH         => $params{is64bit} ? 'x86_64' : 'i586',
            SYSTEM_CATEGORY => $systemCategory
        };

    }

    return $list;
}

sub _addSoftware {
    my (%params) = @_;

    my $entry = $params{entry};

    # avoid duplicates
    return if $seen->{$entry->{NAME}}->{$entry->{ARCH}}{$entry->{VERSION} || '_undef_'}++;

    $params{inventory}->addEntry(section => 'SOFTWARES', entry => $entry);
}

sub _processMSIE {
    my (%params) = @_;

    my $name = $params{is64bit} ?
        "Internet Explorer (64bit)" : "Internet Explorer";

    # Will use key last write date as INSTALLDATE
    my $installedkey = $params{machKey}->{"SOFTWARE/Microsoft/Internet Explorer"};

    my $version = $installedkey->{"/svcVersion"} || $installedkey->{"/Version"};

    return unless $version; # Not installed

    _addSoftware(
        inventory => $params{inventory},
        entry     => {
            FROM        => "registry",
            ARCH        => $params{is64bit} ? 'x86_64' : 'i586',
            NAME        => $name,
            VERSION     => $version,
            PUBLISHER   => "Microsoft Corporation",
            INSTALLDATE => _dateFormat(_keyLastWriteDateString($installedkey))
        }
    );

}

1;
