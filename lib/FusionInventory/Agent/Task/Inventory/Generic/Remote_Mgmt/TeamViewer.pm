package FusionInventory::Agent::Task::Inventory::Generic::Remote_Mgmt::TeamViewer;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    if ($OSNAME eq 'MSWin32') {

        FusionInventory::Agent::Tools::Win32->use();

        return defined getRegistryKey(
            path => is64bit() ?
                "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer" :
                "HKEY_LOCAL_MACHINE/SOFTWARE/TeamViewer",
            logger => $params{logger}
        );
    }

    return canRun('teamviewer');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $teamViewerID = _getID(logger => $logger);
    if (defined($teamViewerID)) {
        $logger->debug('Found TeamViewerID : ' . $teamViewerID) if ($logger);

        $inventory->addEntry(
            section => 'REMOTE_MGMT',
            entry   => {
                ID   => $teamViewerID,
                TYPE => 'teamviewer'
            }
        );
    } else {
        $logger->debug('TeamViewerID not found') if ($logger);
    }
}

sub _getID {
    my (%params) = @_;

    if ($OSNAME eq 'MSWin32') {

        FusionInventory::Agent::Tools::Win32->use();

        my $clientid = getRegistryValue(
            path   => is64bit() ?
                "HKEY_LOCAL_MACHINE/SOFTWARE/Wow6432Node/TeamViewer/ClientID" :
                "HKEY_LOCAL_MACHINE/Software/TeamViewer/ClientID",
            %params
        );

        return $clientid ? hex($clientid) || $clientid : undef ;
    }

    return getFirstMatch(
        command => "teamviewer --info",
        pattern => qr/TeamViewer ID:(?:\033\[0m|\s)*(\d+)\s+/,
        %params
    );
}

1;
