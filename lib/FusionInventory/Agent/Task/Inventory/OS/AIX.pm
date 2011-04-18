package FusionInventory::Agent::Task::Inventory::OS::AIX;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'aix';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Operating system informations
    my $OSName = getFirstLine(command => 'uname -s');

    # AIX OSVersion = oslevel, OSComment=oslevel -r affiche niveau de maintenance
    my $OSVersion = getFirstLine(command => 'oslevel');
    my $OSLevel = getFirstLine(command => 'oslevel -r');
    my @tabOS = split(/-/,$OSLevel);
    my $OSComment = "Maintenance Level : $tabOS[1]";

    $OSVersion =~ s/(.0)*$//;
    $inventory->setHardware({
        OSNAME     => "$OSName $OSVersion",
        OSCOMMENTS => $OSComment,
        OSVERSION  => $OSLevel,
    });
}

1;
