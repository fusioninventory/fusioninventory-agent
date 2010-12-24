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

# check if Solaris 10 release is higher than 08/07
sub _check_solaris_valid_release{
    my ($releaseFile) = @_;

    my $handle;
    if (!open $handle, '<', $releaseFile) {
        warn "Can't open $releaseFile: $ERRNO";
        return;
    }

    my @lines = 
        grep { /Solaris/ }
        <$handle>;
    close $handle;

    my $release = $lines[0];
    my $year;
    if ($release =~ m/Solaris 10 (\d)\/(\d+)/) {
        $release = $1;
        $year = $2;
    } elsif ($release =~ /OpenSolaris 20(\d+)\.(\d+)\s/) {
        $release = $1;
        $year = $2;
    } else {
        return 0;
    }

    if ($year <= 7 and $release < 8) {
        return 0;
    }

    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @zones = 
        grep { !/global/ }
        `/usr/sbin/zoneadm list -p`;

    foreach my $zone (@zones) {
        my ($zoneid, $zonename, $zonestatus, $pathroot , $uuid) = split(/:/, $zone);
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
        my @lines =
            grep { /mcap/ }
            <$handle>;
        close $handle;

        my $memcap = $lines[0];
        $memcap =~ s/[^\d]+//g;
        my $memory = $memcap ?
            $memcap / 1024 / 1024 : undef;

        my $vcpu = getFirstLine(command => '/usr/sbin/psrinfo -p');

        my $machine = {
            MEMORY    => $memory,
            NAME      => $zonename,
            UUID      => $uuid,
            STATUS    => $zonestatus,
            SUBSYSTEM => "Solaris Zones",
            VMTYPE    => "Solaris Zones",
            VMID      => $zoneid,
            VCPU      => $vcpu,
        };

        $inventory->addVirtualMachine($machine);
    }
}

1;
