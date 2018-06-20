package FusionInventory::Agent::Task::Inventory::Win32::Softwares;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);
use File::Basename;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Win32::Constants;

my $seen = {};

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{software};
}

sub isEnabledForRemote {
    my (%params) = @_;

    return !$params{no_category}->{software};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $is64bit = is64bit();

    my $softwares64 = _getSoftwaresList( is64bit => $is64bit ) || [];
    foreach my $software (@$softwares64) {
        _addSoftware(inventory => $inventory, entry => $software);
    }

    _processMSIE(
        inventory => $inventory,
        is64bit   => $is64bit
    );

    if ($params{scan_profiles}) {
        _loadUserSoftware(
            inventory => $inventory,
            is64bit   => $is64bit,
            logger    => $logger
        );
    } else {
        $logger->debug(
            "'scan-profiles' configuration parameter disabled, " .
            "ignoring software in user profiles"
        );
    }

    if ($is64bit) {
        my $softwares32 = _getSoftwaresList(
            path    => "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall",
            is64bit => 0
        ) || [];
        foreach my $software (@$softwares32) {
            _addSoftware(inventory => $inventory, entry => $software);
        }

        _processMSIE(
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

    # Reset seen hash so we can see softwares in later same run inventory
    $seen = {};
}

sub _loadUserSoftware {
    my (%params) = @_;

    my $userList = _getUsersFromRegistry(%params);
    return unless $userList;

    my $inventory = $params{inventory};
    my $is64bit   = $params{is64bit};
    my $logger    = $params{logger};

    foreach my $profileName (keys %$userList) {
        my $userName = $userList->{$profileName}
            or next;

        my $profileSoft = "HKEY_USERS/$profileName/SOFTWARE/";
        $profileSoft .= is64bit() && !$is64bit ?
                "Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall" :
                "Microsoft/Windows/CurrentVersion/Uninstall";

        my $softwares = _getSoftwaresList(
            path      => $profileSoft,
            is64bit   => $is64bit,
            userid    => $profileName,
            username  => $userName
        ) || [];
        next unless @$softwares;
        my $nbUsers = scalar(@$softwares);
        $logger->debug2('_loadUserSoftwareFromHKey_Users() : add of ' . $nbUsers . ' softwares in inventory');
        foreach my $software (@$softwares) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
    }
}

sub _getUsersFromRegistry {
    my (%params) = @_;

    my $profileList = getRegistryKey(
        path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProfileList',
        wmiopts => { # Only used for remote WMI optimization
            values  => [ qw/ProfileImagePath Sid/ ],
        }
    );

    next unless $profileList;

    my $userList;
    foreach my $profileName (keys %$profileList) {
        next unless $profileName =~ m{/$};
        next unless length($profileName) > 10;

        my $profilePath = $profileList->{$profileName}{'/ProfileImagePath'};
        my $sid = $profileList->{$profileName}{'/Sid'};
        next unless $sid;
        next unless $profilePath;
        my $user = basename($profilePath);
        $profileName =~ s|/$||;
        $userList->{$profileName} = $user;
    }

    return $userList;
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

    my $softwares = getRegistryKey(
        path    => "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall",
        wmiopts => { # Only used for remote WMI optimization
            values  => [ qw/
                DisplayName Comments HelpLink ReleaseType DisplayVersion
                Publisher URLInfoAbout UninstallString InstallDate MinorVersion
                MajorVersion NoRemove SystemComponent
                / ]
        },
        %params
    );

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

        #----- SQL Server -----
        # Versions >= SQL Server 2008 (tested with 2008/R2/2012/2016) : "SQL Server xxxx Database Engine Services"
        if ($software->{NAME} =~ /^(SQL Server.*)(\sDatabase Engine Services)/) {
            my $sqlEditionValue = _getSqlEdition(
                softwarename    => $software->{NAME},
                softwareversion => $software->{VERSION}
            );
            if ($sqlEditionValue) {
                $software->{NAME} = $1." ".$sqlEditionValue.$2;
            }
        # Versions = SQL Server 2005 : "Microsoft SQL Server xxxx"
        # "Uninstall" registry key does not contains Version : use default named instance.
        } elsif ($software->{NAME} =~ /^(Microsoft SQL Server 200[0-9])$/ and defined($software->{VERSION})) {
            my $sqlEditionValue = _getSqlEdition(
                softwarename    => $software->{NAME},
                softwareversion => $software->{VERSION}
            );
            if ($sqlEditionValue) {
                $software->{NAME} = $1." ".$sqlEditionValue;
            }
        }
        #----------

        push @list, $software;
    }

    # It's better to return ref here as the array can be really large
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
    my $installedkey = getRegistryKey(
        path   => is64bit() && !$params{is64bit} ?
            "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/Internet Explorer" :
            "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Internet Explorer",
        wmiopts => { # Only used for remote WMI optimization
            values  => [ qw/svcVersion Version/ ],
            subkeys => 0
        }
    );

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

# List of SQL Instances
sub _getSqlEdition {
    my (%params) = @_;

    my $softwareName = $params{softwarename};
    my $softwareVersion = $params{softwareversion};

    # Registry access for SQL Instances
    my $sqlinstancesList = getRegistryKey(
        path => "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Microsoft SQL Server/Instance Names/SQL"
    );
    return unless $sqlinstancesList;

    # List of SQL Instances
    my $sqlinstanceEditionValue;
    foreach my $sqlinstanceName (keys %$sqlinstancesList) {
        my $sqlinstanceValue = $sqlinstancesList->{$sqlinstanceName};
        # Get version and edition for each instance
        $sqlinstanceEditionValue = _getSqlInstancesVersions(
            SOFTVERSION => $softwareVersion,
            VALUE       => $sqlinstanceValue
        );
        last if $sqlinstanceEditionValue;
    }
    return $sqlinstanceEditionValue;
}

# SQL Instances versions
# Return version and edition for each instance
sub _getSqlInstancesVersions {
    my (%params) = @_;

    my $softwareVersion  = $params{SOFTVERSION};
    my $sqlinstanceValue = $params{VALUE};

    my $sqlinstanceVersions = getRegistryKey(
        path => "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Microsoft SQL Server/" . $sqlinstanceValue . "/Setup"
    );
    return unless ($sqlinstanceVersions && $sqlinstanceVersions->{'/Version'});

    return unless $sqlinstanceVersions->{'/Version'} eq $softwareVersion;

    # If software version match instance one
    return $sqlinstanceVersions->{'/Edition'};
}

1;
