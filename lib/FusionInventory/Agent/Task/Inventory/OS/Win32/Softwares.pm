package FusionInventory::Agent::Task::Inventory::OS::Win32::Softwares;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32;
use Win32::OLE('in');
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    my ($params) = @_;

    return !$params->{config}->{no_software};
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    if (is64bit()) {

        # I don't know why but on Vista 32bit, KEY_WOW64_64KEY is able to read
        # 32bit entries. This is not the case on Win2003 and if I correctly
        # understand MSDN, this sounds very odd

        my $machKey64 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_64KEY
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares64 =
            $machKey64->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        _processSoftwares({
            inventory => $inventory,
            softwares => $softwares64bit,
            is64bit   => 1
        });

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32KEY
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares32 =
            $machKey32->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        _processSoftwares({
            inventory => $inventory,
            softwares => $softwares32,
            is64bit => 0
        });
    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ()
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares =
            $machKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        _processSoftwares({
            inventory => $inventory,
            softwares => $softwares,
            is64bit => 0
        });

    }

}

sub _hexToDec {
    my ($val) = @_;

    return unless $val;

    return $val unless $val =~ /^0x/;

    $val =~ s/^0x0*//;
    $val =~ hex($val);

    return $val;
}

sub _dateFormat {
    my ($date) = @_; 

    return unless $date;

    return unless $date =~ /^(\d{4})(\d{2})(\d{2})/;

    return "$3/$2/$1";
}

sub _processSoftwares {
    my ($params) = @_;

    my $softwares = $params->{softwares};
    my $inventory = $params->{inventory};
    my $is64bit   = $params->{is64bit};

    foreach my $rawGuid (keys %$softwares) {
        my $data = $softwares->{$rawGuid};
        next unless keys %$data;
        
        my $guid = $rawGuid;
        $guid =~ s/\/$//; # drop the tailing / 

        # odd, found on Win2003
        next unless keys %$data > 2;

        my $name = encodeFromRegistry($data->{'/DisplayName'});
        # Use the folder name if there is no DisplayName
        $name = encodeFromRegistry($guid) unless $name;
        my $comments = encodeFromRegistry($data->{'/Comments'});
        my $version = encodeFromRegistry($data->{'/DisplayVersion'});
        my $publisher = encodeFromRegistry($data->{'/Publisher'});
        my $urlInfoAbout = encodeFromRegistry($data->{'/URLInfoAbout'});
        my $helpLink = encodeFromRegistry($data->{'/HelpLink'});
        my $uninstallString = encodeFromRegistry($data->{'/UninstallString'});
        my $noRemove;
        my $releaseType = encodeFromRegistry($data->{'/ReleaseType'});
        my $installDate = dateFormat($data->{'/InstallDate'});
        my $versionMinor = hexToDec($data->{'/VersionMinor'});
        my $versionMajor = hexToDec($data->{'/VersionMajor'});

        if ($data->{'/NoRemove'}) {
            $noRemove = ($data->{'/NoRemove'} =~ /1/)?1:0;
        }

        # Workaround for #415
        $version =~ s/[\000-\037].*// if $version;

        $inventory->addEntry({
            section => 'SOFTWARES',
            entry   => {
                COMMENTS         => $comments,
    #            FILESIZE => $filesize,
    #            FOLDER => $folder,
                FROM             => "registry",
                HELPLINK         => $helpLink,
                INSTALLDATE      => $installDate,
                NAME             => $name,
                NOREMOVE         => $noRemove,
                RELEASETYPE      => $releaseType,
                PUBLISHER        => $publisher,
                UNINSTALL_STRING => $uninstallString,
                URL_INFO_ABOUT   => $urlInfoAbout,
                VERSION          => $version,
                VERSION_MINOR    => $versionMinor,
                VERSION_MAJOR    => $versionMajor,
                IS64BIT          => $is64bit,
                GUID             => $guid,
            },
            noDuplicated => 1
        });
    }
}

1;
