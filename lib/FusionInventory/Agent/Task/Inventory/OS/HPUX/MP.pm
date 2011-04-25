package FusionInventory::Agent::Task::Inventory::OS::HPUX::MP;

use strict;
use warnings;

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

    my $ipaddress = can_run('/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi') ?
        getFirstMatch(
            command => '/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi',
            pattern => qr/chpMiscData.RIBLink = "http.*\/([0-9.]+)";/
        ) :
        getFirstMatch(
            command => '/opt/sfm/bin/CIMUtil -e root/cimv2 HP_ManagementProcessor',
            pattern => qr/IPAddress\s+:\s+([0-9.]+)/
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
