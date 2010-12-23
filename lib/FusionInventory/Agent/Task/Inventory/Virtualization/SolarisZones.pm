package FusionInventory::Agent::Task::Inventory::Virtualization::SolarisZones;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return 
        can_run('zoneadm') &&
        _check_solaris_valid_release('/etc/release');
}

sub _check_solaris_valid_release{
    my ($releaseFile) = @_;

    #check if Solaris 10 release is higher than 08/07
    my @rlines;
    my $release_file;
    my $release;
    my $year;

    my $handle;
    if (!open $handle, '<', $releaseFile) {
        warn "Can't open $releaseFile: $ERRNO";
        return;
    }
    @rlines = <$handle>;
    close $handle;

    @rlines = grep(/Solaris/,@rlines);
    $release = $rlines[0];
    if ($release =~ m/Solaris 10 (\d)\/(\d+)/) {
        $release = $1;
        $year = $2;
    } elsif ($release =~ /OpenSolaris 20(\d+)\.(\d+)\s/) {
        $release = $1;
        $year = $2;
    } else {
        return 0;
    }

    if ($year <= 7 and $release < 8 ){
        return 0;
    }
    1 
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @zones = `/usr/sbin/zoneadm list -p`;
    @zones = grep (!/global/,@zones);

    foreach my $zone (@zones) {
        my ($zoneid,$zonename,$zonestatus,$pathroot,$uuid)=split(/:/,$zone);
        # 
        # Memory considerations depends on rcapd or project definitions
        # Little hack, I go directly in /etc/zones reading mcap physcap for each zone.
        my $zonefile = "/etc/zones/$zonename.xml";

        my $handle;
        if (!open $handle, '<', $zonefile) {
            warn "Can't open $zonefile: $ERRNO";
            $logger->debug("Failed to open $zonefile");
            next;
        }
        my @lines = <$handle>;
        close $handle;

        @lines = grep(/mcap/,@lines);
        my $memcap = $lines[0];
        $memcap=~ s/[^\d]+//g;
        my $memory=$memcap/1024/1024;
        if (!$memcap){
            $memory="";
        }

        my $vcpu = getFirstLine(command => '/usr/sbin/psrinfo -p');
        if (!$vcpu){
            $vcpu="";
        }

        my $machine = {
            MEMORY => $memory,
            NAME => $zonename,
            UUID => $uuid,
            STATUS => $zonestatus,
            SUBSYSTEM => "Solaris Zones",
            VMTYPE => "Solaris Zones",
            VMID => $zoneid,
            VCPU => $vcpu,
        };

        $inventory->addVirtualMachine($machine);
    }
}

1;
