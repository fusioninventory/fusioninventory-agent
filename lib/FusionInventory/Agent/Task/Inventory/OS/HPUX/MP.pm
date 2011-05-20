package FusionInventory::Agent::Task::Inventory::OS::HPUX::MP;

use strict;
use warnings;

use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;

#TODO driver pcislot virtualdev

sub isInventoryEnabled {
    return
        can_run('/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi') ||
        can_run('/opt/sfm/bin/CIMUtil');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my ($command, $pattern);
    if (can_run('/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi')) {
        $command = '/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi';
        $pattern = qr{RIBLink = "https?://($ip_address_pattern)";};
    } else {
        $command = '/opt/sfm/bin/CIMUtil -e root/cimv2 HP_ManagementProcessor';
        $pattern = qr{^IPAddress\s+:\s+($ip_address_pattern)};
    }

    my $ipaddress = getFirstMatch(
        command => $command,
        pattern => $pattern
    );

    $inventory->addEntry(
        section => 'NETWORKS',
        entry => {
            DESCRIPTION => 'Management Interface - HP MP',
            TYPE        => 'Ethernet',
            MANAGEMENT  => 'MP',
            IPADDRESS   => $ipaddress,
        }
    );

}

1;
