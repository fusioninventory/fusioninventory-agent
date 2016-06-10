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

    $logger->debug("Antivirus.pm : doInventory()") if defined $logger;
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
                $logger->debug("Antivirus.pm : just before _addMcAfeeData(), antivirus found is McAfee");
                _addMcAfeeData($antivirus, $logger);
                $logger->debug("Antivirus.pm : just after _addMcAfeeData()");
            }

            $inventory->addEntry(
                section => 'ANTIVIRUS',
                entry   => $antivirus
            );
        }
    }
}

sub _addMcAfeeData {
    my ($hashref, $logger) = @_;

    my $path;
    if (is64bit() && defined getRegistryKey(path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/McAfee/AVEngine')) {
        $path = 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/McAfee/AVEngine';
    } else {
        $path = 'HKEY_LOCAL_MACHINE/SOFTWARE/McAfee/AVEngine';
    }

    # get the values in registry
    my $avDatDate = getRegistryValue(
        path     => $path . '/AVDatDate' ,
        withtype => 0
    );
    my $avDatVersion = getRegistryValue(
        path     => $path . '/AVDatVersion' ,
        withtype => 0
    );
    my $avDatVersionMinor = getRegistryValue(
        path     => $path . '/AVDatVersionMinor' ,
        withtype => 0
    );
    my $engineVersion32Major = getRegistryValue(
        path     => $path . '/EngineVersion32Major' ,
        withtype => 0
    );
    my $engineVersion32Minor = getRegistryValue(
        path     => $path . '/EngineVersion32Minor' ,
        withtype => 0
    );
    my $engineVersion64Major = getRegistryValue(
        path     => $path . '/EngineVersionMajor' ,
        withtype => 0
    );
    my $engineVersion64Minor = getRegistryValue(
        path     => $path . '/EngineVersionMinor' ,
        withtype => 0
    );


    $logger->debug2('$avDatDate : ' . ($avDatDate || 'undef'));
    $logger->debug2('$avDatVersion : ' . ($avDatVersion || 'undef'));
    $logger->debug2('$avDatVersionMinor : ' . ($avDatVersionMinor || 'undef'));
    $logger->debug2('$engineVersion32Major : ' . ($engineVersion32Major || 'undef'));
    $logger->debug2('$engineVersion32Minor : ' . ($engineVersion32Minor || 'undef'));
    $logger->debug2('$engineVersion64Major : ' . ($engineVersion64Major || 'undef'));
    $logger->debug2('$engineVersion64Minor : ' . ($engineVersion64Minor || 'undef'));

    # fill the inventory
    if (defined $avDatDate) {
        my $datFileCreation = encodeFromRegistry( $avDatDate );
        # from YYYY/MM/DD to DD/MM/YYYY
        if ($datFileCreation =~ /(\d\d\d\d)\/(\d\d)\/(\d\d)/) {
            $datFileCreation = join( '/', ($3, $2, $1) );
        }
        $hashref->{DATFILECREATION} = $datFileCreation;
    }
    if (defined $avDatVersion && defined $avDatVersionMinor) {
        $hashref->{DATFILEVERSION} = _formatMcAfeeVersion($avDatVersion, $avDatVersionMinor);
    }
    if (defined $engineVersion32Major && defined $engineVersion32Minor) {
        $hashref->{ENGINEVERSION32} = _formatMcAfeeVersion($engineVersion32Major, $engineVersion32Minor);
    }
    if (defined $engineVersion64Major && defined $engineVersion64Minor) {
        $hashref->{ENGINEVERSION64} = _formatMcAfeeVersion($engineVersion64Major, $engineVersion64Minor);
    }
}

sub _formatMcAfeeVersion {
    my ($str1, $str2) = shift;

    my $str = sprintf("%04h.%04h", $str1, $str2);

    return $str;
}

1;
