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
    my @OSLevelParts = split(/-/, $OSLevel);

    my $Revision = getFirstLine(command => 'oslevel -s');
    my @RevisionParts = split(/-/, $Revision);

    $inventory->setHardware({
        OSNAME     => "$OSName $OSVersion",
        OSVERSION  => $OSLevel,
        OSCOMMENTS => "Maintenance Level: $OSLevelParts[1]"
    });

    $inventory->setOperatingSystem({
        NAME         => "AIX",
        VERSION      => $OSVersion,
        SERVICE_PACK => "$RevisionParts[2]-$RevisionParts[3]",
        FULL_NAME    => "$OSName $OSVersion"
    });
}

1;
