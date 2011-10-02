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

my $seen;

sub isEnabled {
    my (%params) = @_;

    return !$params{no_software};
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
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares64 =
            $machKey64->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

	foreach my $software (_getSoftwares(
	    softwares => $softwares64,
	    is64bit   => 1
        )) {
	    $inventory->addEntry(section => 'SOFTWARES', entry => $software);
	}

        my $machKey32 = $Registry->Open('LMachine', {
            Access => KEY_READ | KEY_WOW64_32 ## no critic (ProhibitBitwise)
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares32 =
            $machKey32->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

	foreach my $software (_getSoftwares(
	    softwares => $softwares32,
	    is64bit   => 0
        )) {
	    $inventory->addEntry(section => 'SOFTWARES', entry => $software);
	}
    } else {
        my $machKey = $Registry->Open('LMachine', {
            Access => KEY_READ
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $softwares =
            $machKey->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

	foreach my $software (_getSoftwares(
	    softwares => $softwares,
	    is64bit   => 0
        )) {
	    $inventory->addEntry(section => 'SOFTWARES', entry => $software);
	}
    }
}

sub _dateFormat {
    my ($date) = @_; 

    return unless $date;

    return unless $date =~ /^(\d{4})(\d{2})(\d{2})/;

    return "$3/$2/$1";
}

sub _getSoftwares {
    my (%params) = @_;

    my $softwares = $params{softwares};
    my $is64bit   = $params{is64bit};

    my @softwares;

    foreach my $rawGuid (keys %$softwares) {
        my $data = $softwares->{$rawGuid};
        # odd, found on Win2003
        next unless keys %$data > 2;

        # See bug #927
        # http://stackoverflow.com/questions/2639513/duplicate-entries-in-uninstall-registry-key-when-compiling-list-of-installed-soft
        next if $data->{'/SystemComponent'};

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
            NO_REMOVE        => $data->{'/NoRemove'} && 
                                $data->{'/NoRemove'} =~ /1/,
            IS64BIT          => $is64bit,
            GUID             => $guid,
        };

        # Workaround for #415
        $software->{VERSION} =~ s/[\000-\037].*// if $software->{VERSION};

        # avoid duplicates
        next if $seen->{$software->{NAME}}->{$software->{VERSION}}++;

	push @softwares, $software;
    }

    return @softwares;
}

1;
