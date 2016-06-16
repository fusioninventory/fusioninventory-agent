package FusionInventory::Agent::Task::Inventory::Win32::AntiVirus;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

my $seen;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $logger;
    $logger = $params{logger};

    my $inventory = $params{inventory};

    # Doesn't works on Win2003 Server
    # On Win7, we need to use SecurityCenter2
    foreach my $instance (qw/SecurityCenter SecurityCenter2/) {
        my $moniker = "winmgmts:{impersonationLevel=impersonate,(security)}!//./root/$instance";

        foreach my $object (getWMIObjects(
                moniker    => $moniker,
                class      => "AntiVirusProduct",
                properties => [ qw/
                    companyName displayName instanceGuid onAccessScanningEnabled
                    productUptoDate versionNumber productState
               / ]
        )) {
            next unless $object;

            my $antivirus = {
                COMPANY  => $object->{companyName},
                NAME     => $object->{displayName},
                GUID     => $object->{instanceGuid},
                VERSION  => $object->{versionNumber},
                ENABLED  => $object->{onAccessScanningEnabled},
                UPTODATE => $object->{productUptoDate}
            };

            if ($object->{productState}) {
                my $bin = sprintf( "%b\n", $object->{productState});
# http://blogs.msdn.com/b/alejacma/archive/2008/05/12/how-to-get-antivirus-information-with-wmi-vbscript.aspx?PageIndex=2#comments
                if ($bin =~ /(\d)\d{5}(\d)\d{6}(\d)\d{5}$/) {
                    $antivirus->{UPTODATE} = $1 || $2;
                    $antivirus->{ENABLED}  = $3 ? 0 : 1;
                }
            }

            # avoid duplicates
            next if $seen->{$antivirus->{NAME}}->{$antivirus->{VERSION}||'_undef_'}++;

            # McAfee data
            if ($antivirus->{NAME} =~ /McAfee/i) {
                my $info = _getMcAfeeInfo($logger);
                $antivirus->{$_} = $info->{$_} foreach keys %$info;
            }

            $inventory->addEntry(
                section => 'ANTIVIRUS',
                entry   => $antivirus
            );
        }
    }
}

sub _getMcAfeeInfo {
    my ($logger) = @_;

    my $path;
    if (is64bit() && defined getRegistryKey(path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/McAfee/AVEngine')) {
        $path = 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/McAfee/AVEngine';
    } else {
        $path = 'HKEY_LOCAL_MACHINE/SOFTWARE/McAfee/AVEngine';
    }

    my %properties = (
        DATFILEVERSION  => [ 'AVDatVersion',         'AVDatVersionMinor' ],
        ENGINEVERSION32 => [ 'EngineVersion32Major', 'EngineVersion32Minor' ],
        ENGINEVERSION64 => [ 'EngineVersionMajor',   'EngineVersionMinor' ],
    );

    my $info;

    # major.minor versions properties
    foreach my $property (keys %properties) {
        my $keys = $properties{$property};
        my $major = getRegistryValue(path => $path . '/' . $keys->[0]);
        my $minor = getRegistryValue(path => $path . '/' . $keys->[1]);
        $info->{$property} = sprintf("%04d.%04d", hex($major), hex($minor))
            if defined $major && defined $major;
    }

    # file creation date property
    my $avDatDate            =
        getRegistryValue(path => $path . '/AVDatDate');

    if (defined $avDatDate) {
        my $datFileCreation = encodeFromRegistry( $avDatDate );
        # from YYYY/MM/DD to DD/MM/YYYY
        if ($datFileCreation =~ /(\d\d\d\d)\/(\d\d)\/(\d\d)/) {
            $datFileCreation = join( '/', ($3, $2, $1) );
        }
        $info->{DATFILECREATION} = $datFileCreation;
    }

    return $info;
}

1;
