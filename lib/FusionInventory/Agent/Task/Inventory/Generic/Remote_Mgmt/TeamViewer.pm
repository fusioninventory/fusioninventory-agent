package FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt::TeamViewer;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('teamviewer');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    if ($logger) {
        $logger->debug('FusionInventory::Agent::Task::Inventory::Remote_Mgmt::TeamViewer');
    }
    my $command = "teamviewer --info";
    my $teamViewerID = _getID(command => $command, logger => $logger);
    $logger->debug('ID : ' . $teamViewerID);
    my $remoteMgmt = {
        ID => $teamViewerID,
        TYPE => 'teamviewer'
    };
    $inventory->addEntry(
        section => 'REMOTE_MGMT', entry => $remoteMgmt
    );

}

sub _getID {
    my (%params) = @_;

    return getFirstMatch(
        pattern => qr/TeamViewer ID:(?:\033\[0m|\s)*(\d+)\s+/,
        %params
    );
}

1;
