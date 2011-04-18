package FusionInventory::Agent::Task::Inventory::OS::Win32::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

# Only run this module if dmidecode has not been found
our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios"];

sub isInventoryEnabled {
    return 1;
}

sub getBiosInfoFromRegistry {

    my $machKey= $Registry->Open('LMachine', {
        Access=> KEY_READ | KEY_WOW64_64
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $data =
        $machKey->{"Hardware/Description/System/BIOS"};

    my $info;

    foreach my $tmpkey (%$data) {
        next unless $tmpkey =~ /^\/(.*)/;
        my $key = $1;

        $info->{$key} = $data->{$tmpkey};
    }

    return $info;
}




sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $smodel;
    my $smanufacturer;
    my $ssn;
    my $enclosureSerial;
    my $baseBoardSerial;
    my $biosSerial;
    my $bdate;
    my $bversion;
    my $bmanufacturer;
    my $mmanufacturer;
    my $msn;
    my $model;
    my $assettag;


    my $registryInfo = getBiosInfoFromRegistry();

    $bdate = $registryInfo->{BIOSReleaseDate};

    foreach my $object (getWmiObjects(
        class      => 'Win32_Bios',
        properties => [ qw/
            SerialNumber Version Manufacturer SMBIOSBIOSVersion BIOSVersion
        / ]
    )) {
        $biosSerial = $object->{SerialNumber};
        $ssn = $object->{SerialNumber} unless $ssn;
        $bmanufacturer = $object->{Manufacturer} unless $bmanufacturer;
        $bversion = $object->{SMBIOSBIOSVersion} unless $bversion;
        $bversion = $object->{BIOSVersion} unless $bversion;
        $bversion = $object->{Version} unless $bversion;
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_ComputerSystem',
        properties => [ qw/
            Manufacturer Model
        / ]
    )) {
        $smanufacturer = $object->{Manufacturer} unless $smanufacturer;
        $model = $object->{Model} unless $model;
    }

    foreach my $object (getWmiObjects(
            class      => 'Win32_SystemEnclosure',
            properties => [ qw/
                SerialNumber SMBIOSAssetTag
            / ]
    )) {
        $enclosureSerial = $object->{SerialNumber} ;
        $ssn = $object->{SerialNumber} unless $ssn;
        $assettag = $object->{SMBIOSAssetTag} unless $assettag;
    }

    foreach my $object (getWmiObjects(
            class => 'Win32_BaseBoard',
            properties => [ qw/
                SerialNumber Product Manufacturer
            / ]
    )) {
        $baseBoardSerial = $object->{SerialNumber};
        $ssn = $object->{SerialNumber} unless $ssn;
        $smodel = $object->{Product} unless $smodel;
        $smanufacturer = $object->{Manufacturer} unless $smanufacturer;

    }

    $inventory->setBios(
        SMODEL          => $smodel,
        SMANUFACTURER   => $smanufacturer,
        SSN             => $ssn,
        BDATE           => $bdate,
        BVERSION        => $bversion,
        BMANUFACTURER   => $bmanufacturer,
        MMANUFACTURER   => $mmanufacturer,
        MSN             => $msn,
        MMODEL          => $model,
        ASSETTAG        => $assettag,
        ENCLOSURESERIAL => $enclosureSerial,
        BASEBOARDSERIAL => $baseBoardSerial,
        BIOSSERIAL      => $biosSerial,
    );

    my $vmsystem;
# it's more reliable to do a regex on the CPU NAME
# QEMU Virtual CPU version 0.12.4
#    if ($bmanufacturer eq 'Bochs' || $model eq 'Bochs') {
#        $vmsystem = 'QEMU';
#    } els

    if ($bversion eq 'VirtualBox' || $model eq 'VirtualBox') {
        $vmsystem = 'VirtualBox';
    }

    if ($vmsystem) {
        $inventory->setHardware(
            VMSYSTEM => $vmsystem 
        );
    }

}

1;
