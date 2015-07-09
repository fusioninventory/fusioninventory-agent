package FusionInventory::Agent::Task::Inventory::AIX;

use strict;
use warnings;

use English qw(-no_match_vars);

use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return $OSNAME eq 'aix';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    # Operating system informations
    my $kernelName = getFirstLine(command => 'uname -s');

    my $version = getFirstLine(command => 'oslevel');
    $version =~ s/(.0)*$//;

    my $OSLevel = getFirstLine(command => 'oslevel -r');
    my @OSLevelParts = split(/-/, $OSLevel);

    my $Revision = getFirstLine(command => 'oslevel -s');
    my @RevisionParts = split(/-/, $Revision);

    my $ssn;
    my $vmsystem;
    my $vmid;
    my $vmname;
    my $vmhostserial;

    my @infos = getLsvpdInfos(logger => $logger);

    # Get the BIOS version from the System Microcode Image (MI) version, in
    # 'System Firmware' section of VPD, containing three space separated values:
    # - the microcode image the system currently runs
    # - the 'permanent' microcode image
    # - the 'temporary' microcode image
    # See http://www.systemscanaix.com/sample_reports/aix61/hardware_configuration.html
    my $bios_version;

    my $system = first { $_->{DS} eq 'System Firmware' } @infos;
    if ($system) {
        # we only return the currently booted firmware
        my @firmwares = split(' ', $system->{MI});
        $bios_version = $firmwares[0];
    }

    my $vpd = first { $_->{DS} eq 'System VPD' } @infos;

    my $unameL = getFirstLine(command => 'uname -L');
    # LPAR partition can access the serial number of the host computer
    # If we are such system, the serial number must be stored in the
    # VMHOSTSERIAL key.
    if ($unameL && $unameL =~ /^(\d+)\s+(\S+)/) {
        $vmsystem = "AIX_LPAR";
        $vmname = $2;
        $vmhostserial = $vpd->{SE};
        $ssn = "aixlpar-$vmhostserial-$vmid";
    } else {
        $ssn = $vpd->{SE};
    }

    $inventory->setHardware({
        OSNAME     => "$kernelName $version",
        OSVERSION  => $OSLevel,
        OSCOMMENTS => "Maintenance Level: $OSLevelParts[1]",
        VMNAME     => $vmname,
        VMSYSTEM   => $vmsystem,
        VMHOSTSERIAL => $vmhostserial
    });

    $inventory->setOperatingSystem({
        NAME         => 'AIX',
        FULL_NAME    => "$kernelName $version",
        VERSION      => $version,
        SERVICE_PACK => "$RevisionParts[2]-$RevisionParts[3]",
    });

    $inventory->setBios({
        BMANUFACTURER => 'IBM',
        SMANUFACTURER => 'IBM',
        SMODEL        => $vpd->{TM},
        SSN           => $ssn,
        BVERSION      => $bios_version,
    });

}

1;
