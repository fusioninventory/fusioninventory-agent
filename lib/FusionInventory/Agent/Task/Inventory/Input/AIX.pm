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

    $inventory->setHardware({
        OSNAME     => "$OSName $OSVersion",
        OSVERSION  => $OSLevel,
        OSCOMMENTS => $OSComment,
    });

    $inventory->setOperatingSystem({
        NAME                 => "AIX",
        VERSION              => $OSVersion,
        FULL_NAME            => "$OSName $OSVersion"
    });
}

1;
