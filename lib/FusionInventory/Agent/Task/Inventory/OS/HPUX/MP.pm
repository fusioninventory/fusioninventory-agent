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

    my $ipaddress;

    if ( can_run('/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi') ) {    
        foreach (`/opt/hpsmh/data/htdocs/comppage/getMPInfo.cgi`) {
            if ( /parent.frames.CHPAppletFrame.chpMiscData.RIBLink = "http.*\/([0-9.]+)";/ ) {
                $ipaddress = $1;
            }
        }
    } else { #it off course can run /opt/sfm/bin/CIMUtil
        foreach (`/opt/sfm/bin/CIMUtil -e root/cimv2 HP_ManagementProcessor`) {
            if ( /IPAddress\s+:\s+([0-9.]+)/ ) {
                $ipaddress = $1;
            }
        }
    }

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
