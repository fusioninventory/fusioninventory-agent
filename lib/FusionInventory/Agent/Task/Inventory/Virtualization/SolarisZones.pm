package FusionInventory::Agent::Task::Inventory::Virtualization::SolarisZones;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled { 
    return unless can_run('zoneadm'); 
    return unless check_solaris_valid_release('/etc/release');
}
sub check_solaris_valid_release{
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
    my @zones;
    my @lines;
    my $zone;
    my $zoneid;
    my $zonename;
    my $zonestatus;
    my $zonefile;
    my $pathroot;
    my $uuid;
    my $memory;
    my $memcap;
    my $vcpu;
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    @zones = `/usr/sbin/zoneadm list -p`;
    @zones = grep (!/global/,@zones);

    foreach my $zone (@zones) {	
        ($zoneid,$zonename,$zonestatus,$pathroot,$uuid)=split(/:/,$zone);
        # 
        # Memory considerations depends on rcapd or project definitions
        # Little hack, I go directly in /etc/zones reading mcap physcap for each zone.
        $zonefile = "/etc/zones/$zonename.xml";

        my $handle;
        if (!open $handle, '<', $zonefile) {
            warn "Can't open $zonefile: $ERRNO";
            $logger->debug("Failed to open $zonefile");
            next;
        }
        @lines = <$handle>;
        close $handle;

        @lines = grep(/mcap/,@lines);
        $memcap = $lines[0];
        $memcap=~ s/[^\d]+//g;
        $memory=$memcap/1024/1024;
        if (!$memcap){
            $memory="";
        }

        $vcpu = `/usr/sbin/psrinfo -p`; 
        chomp $vcpu;
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
