package FusionInventory::Agent::Task::Inventory::Input::Win32::Softwares;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32;
use Win32::OLE('in');
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

my $seen = {};

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{software};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    if (is64bit()) {

        # I don't know why but on Vista 32bit, KEY_WOW64_64 is able to read
        # 32bit entries. This is not the case on Win2003 and if I correctly
        # understand MSDN, this sounds very odd

        my $machKey64 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_64 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

        my $softwares64 =
            $machKey64->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        foreach my $software (_getSoftwares(
            softwares => $softwares64,
            is64bit   => 1
        )) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey64,
            inventory => $inventory,
            is64bit   => 1
        );

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32 ## no critic (ProhibitBitwise)
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

        my $softwares32 =
            $machKey32->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        foreach my $software (_getSoftwares(
            softwares => $softwares32,
            is64bit   => 0,
            logger => $logger
        )) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey32,
            inventory => $inventory,
            is64bit   => 0
        );


    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ
        }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");

        my $softwares =
            $machKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

        foreach my $software (_getSoftwares(
            softwares => $softwares,
            is64bit   => 0
        )) {
            _addSoftware(inventory => $inventory, entry => $software);
        }
        _processMSIE(
            machKey   => $machKey,
            inventory => $inventory,
            is64bit   => 0
        );
    }
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

    return undef;
}

sub _getSoftwares {
    my (%params) = @_;

    my $softwares = $params{softwares};

    my @softwares;

    return unless $softwares;

    foreach my $rawGuid (keys %$softwares) {
        my $data = $softwares->{$rawGuid};

        next unless $data;

        # odd, found on Win2003
        next unless keys %$data > 2;

        my $guid = $rawGuid;
        $guid =~ s/\/$//; # drop the tailing /

        my $software = {
            FROM             => "registry",
            NAME             => encodeFromRegistry($data->{'/DisplayName'}) ||
                                encodeFromRegistry($guid), # folder name
            COMMENTS         => encodeFromRegistry($data->{'/Comments'}),
            HELPLINK         => encodeFromRegistry($data->{'/HelpLink'}),
            RELEASETYPE      => encodeFromRegistry($data->{'/ReleaseType'}),
            VERSION          => encodeFromRegistry($data->{'/DisplayVersion'}),
            PUBLISHER        => encodeFromRegistry($data->{'/Publisher'}),
            URL_INFO_ABOUT   => encodeFromRegistry($data->{'/URLInfoAbout'}),
            UNINSTALL_STRING => encodeFromRegistry($data->{'/UninstallString'}),
            INSTALLDATE      => _dateFormat($data->{'/InstallDate'}),
            VERSION_MINOR    => hex2dec($data->{'/MinorVersion'}),
            VERSION_MAJOR    => hex2dec($data->{'/MajorVersion'}),
            NO_REMOVE        => hex2dec($data->{'/NoRemove'}),
            IS64BIT          => $params{is64bit},
            GUID             => $guid,
        };

        # Workaround for #415
        $software->{VERSION} =~ s/[\000-\037].*// if $software->{VERSION};

        push @softwares, $software;
    }

    return @softwares;
}

sub _addSoftware {
    my (%params) = @_;

    my $entry = $params{entry};

    # avoid duplicates
    return if $seen->{$entry->{NAME}}->{$entry->{IS64BIT}}{$entry->{VERSION} || '_undef_'}++;

    $params{inventory}->addEntry(section => 'SOFTWARES', entry => $entry);
}

sub _processMSIE {
    my (%params) = @_;

    my $name = $params{is64bit} ?
        "Internet Explorer (64bit)" : "Internet Explorer";
    my $version = 
        $params{machKey}->{"SOFTWARE/Microsoft/Internet Explorer/Version"};

    return unless $version; # Not installed

    _addSoftware(
        inventory => $params{inventory},
        entry     => {
            FROM      => "registry",
            IS64BIT   => $params{is64bit},
            NAME      => $name,
            VERSION   => $version,
            PUBLISHER => "Microsoft Corporation"
        }
    );

}

1;
