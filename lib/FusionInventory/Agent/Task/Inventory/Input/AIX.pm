package FusionInventory::Agent::Task::Inventory::Input::AIX;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Input::Generic"];

sub isEnabled {
    return $OSNAME eq 'aix';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Operating system informations
    my $OSName = getFirstLine(command => 'uname -s');

    my $OSVersion = getFirstLine(command => 'oslevel');
    $OSVersion =~ s/(.0)*$//;

    my $OSLevel = getFirstLine(command => 'oslevel -r');
    my @tabOS = split(/-/,$OSLevel);
    my $OSComment = "Maintenance Level : $tabOS[1]";


    my $vmsystem;
    my $vmid;
    my $vmname;

    my @infos = getLsvpdInfos(logger => $logger);

    my $bversion;
    my $system = first { $_->{DS} eq 'System Firmware' } @infos;
    $bversion = $system->{RM} if $system;

    my $platform = first { $_->{DS} eq 'Platform Firmware' } @infos;
    $bversion .= "(Firmware : $platform->{RM})" if $platform;

    my $vpd = first { $_->{DS} eq 'System VPD' } @infos;

    my $unameL = getFirstLine(command => 'uname -L');
    # LPAR partition can access the serial number of the
    # host compuer.
    # If we are such system, the serial number must be store in
    # the VMHOSTSERIAL key.
    if ($unameL =~ /^(\d+)\s+(\S+)/) {
        $vmsystem = "AIX_LPAR";
        $vmid = $1;
        $vmname = $2;
        $vmhostserial = $vpd->{SE};
        $ssn = "aixlpar-$vmhostserial-$vmid";
    } else {
        $ssn = $vpd->{SE};
    }

    $inventory->setHardware({
        OSNAME     => "$OSName $OSVersion",
        OSVERSION  => $OSLevel,
        OSCOMMENTS => $OSComment,
        VMID       => $vmid,
        VMNAME     => $vmname,
        VMSYSTEM   => $vmsystem,
        VMHOSTSERIAL => $vmhostserial
    });

    $inventory->setOperatingSystem({
        NAME                 => "AIX",
        VERSION              => $OSVersion,
        FULL_NAME            => "$OSName $OSVersion"
    });

    $inventory->setBios({
        BMANUFACTURER => 'IBM',
        SMANUFACTURER => 'IBM',
        SMODEL        => $vpd->{TM},
        SSN           => $ssn,
        BVERSION      => $bersion,
    });

}

1;
