package FusionInventory::Agent::Task::Inventory::Win32::AntiVirus;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub isEnabledForRemote {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $seen;

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

            # Also support WMI access to Windows Defender
            if (!$antivirus->{VERSION} && $antivirus->{NAME} =~ /Windows Defender/i) {
                my ($defender) = getWMIObjects(
                    moniker    => 'winmgmts://./root/microsoft/windows/defender',
                    class      => "MSFT_MpComputerStatus",
                    properties => [ qw/AMProductVersion AntivirusEnabled/ ]
                );
                $antivirus->{VERSION} = $defender->{AMProductVersion}
                    if ($defender && $defender->{AntivirusEnabled} && $defender->{AMProductVersion});
                $antivirus->{COMPANY} = "Microsoft Corporation";
            }

            # Finally try to get version from software installation in registry
            if (!$antivirus->{VERSION} || !$antivirus->{COMPANY}) {
                my $registry = _getAntivirusUninstall($antivirus->{NAME});
                if ($registry) {
                    $antivirus->{VERSION} = encodeFromRegistry($registry->{"/DisplayVersion"})
                        if (!$antivirus->{VERSION} && $registry->{"/DisplayVersion"});
                    $antivirus->{COMPANY} = encodeFromRegistry($registry->{"/Publisher"})
                        if (!$antivirus->{COMPANY} && $registry->{"/Publisher"});
                }
            }

            # avoid duplicates
            next if $seen->{$antivirus->{NAME}}->{$antivirus->{VERSION}||'_undef_'}++;

            # McAfee data
            if ($antivirus->{NAME} =~ /McAfee/i) {
                my $info = _getMcAfeeInfo();
                $antivirus->{$_} = $info->{$_} foreach keys %$info;
            }

            $inventory->addEntry(
                section => 'ANTIVIRUS',
                entry   => $antivirus
            );
        }
    }
}

sub _getAntivirusUninstall {
    my ($name) = @_;

    return unless $name;

    my ($regUninstall, $AVRegUninstall);

    if (is64bit()) {
        $regUninstall = getRegistryKey(
            path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall',
        );
        $AVRegUninstall = first {
            $_->{"/DisplayName"} && $_->{"/DisplayName"} =~ /$name/i;
        } values(%{$regUninstall});
    }

    if (!$AVRegUninstall) {
        $regUninstall = getRegistryKey(
            path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall',
        );
        $AVRegUninstall = first {
            $_->{"/DisplayName"} && $_->{"/DisplayName"} =~ /$name/i;
        } values(%{$regUninstall});
    }

    return $AVRegUninstall;
}

sub _getMcAfeeInfo {

    my %properties = (
        DATFILEVERSION  => [ 'AVDatVersion',         'AVDatVersionMinor' ],
        ENGINEVERSION32 => [ 'EngineVersion32Major', 'EngineVersion32Minor' ],
        ENGINEVERSION64 => [ 'EngineVersionMajor',   'EngineVersionMinor' ],
    );

    my $regvalues = [ 'AVDatDate', map { @{$_} } values(%properties) ];

    my ($info, $macafeeReg);

    if (is64bit()) {
        $macafeeReg = getRegistryKey(
            path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/McAfee/AVEngine',
            wmiopts => { # Only used for remote WMI optimization
                values  => $regvalues
            }
        );
    }

    if (!$macafeeReg) {
        $macafeeReg = getRegistryKey(
            path => 'HKEY_LOCAL_MACHINE/SOFTWARE/McAfee/AVEngine',
            wmiopts => { # Only used for remote WMI optimization
                values  => $regvalues
            }
        );
    }

    return unless $macafeeReg;

    # major.minor versions properties
    foreach my $property (keys %properties) {
        my $keys = $properties{$property};
        my $major = $macafeeReg->{'/' . $keys->[0]};
        my $minor = $macafeeReg->{'/' . $keys->[1]};
        $info->{$property} = sprintf("%04d.%04d", hex2dec($major), hex2dec($minor))
            if defined $major && defined $major;
    }

    # file creation date property
    if ($macafeeReg->{'/AVDatDate'}) {
        my $datFileCreation = encodeFromRegistry($macafeeReg->{'/AVDatDate'});
        # from YYYY/MM/DD to DD/MM/YYYY
        if ($datFileCreation =~ /(\d\d\d\d)\/(\d\d)\/(\d\d)/) {
            $datFileCreation = join( '/', ($3, $2, $1) );
        }
        $info->{DATFILECREATION} = $datFileCreation;
    }

    return $info;
}

1;
