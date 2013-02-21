package FusionInventory::Agent::Task::Inventory::Input::Virtualization::SolarisZones;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return
        canRun('zoneadm') &&
        getZone() eq 'global' &&
        _check_solaris_valid_release('/etc/release');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @zones =
        grep { !/global/ }
        getAllLines(command => '/usr/sbin/zoneadm list -p', logger => $logger);

    foreach my $zone (@zones) {
        my ($zoneid, $zonename, $zonestatus, undef, $uuid) = split(/:/, $zone);

        # Memory considerations depends on rcapd or project definitions
        # Little hack, I go directly in /etc/zones reading mcap physcap for each zone.
        my $zonefile = "/etc/zones/$zonename.xml";

        my $line = getFirstMatch(
            file  => $zonefile,
            pattern => qr/(.*mcap.*)/
        );

        my $memory;

        if ($line) {
            my $memcap = $line;
            $memcap =~ s/[^\d]+//g;
            $memory = $memcap / 1024 / 1024;

        }

        my $vcpu = getFirstLine(command => '/usr/sbin/psrinfo -p');

        $inventory->addEntry(
            section => 'VIRTUALMACHINES',
            entry => {
                MEMORY    => $memory,
                NAME      => $zonename,
                UUID      => $uuid,
                STATUS    => $zonestatus,
                SUBSYSTEM => "Solaris Zones",
                VMTYPE    => "Solaris Zones",
                VMID      => $zoneid,
                VCPU      => $vcpu,
            }
        );
    }
}

# check if Solaris 10 release is higher than 08/07
sub _check_solaris_valid_release{
    my ($releaseFile) = @_;

    my $release = getFirstMatch(
        file => $releaseFile,
        pattern => qr/((?:Open)?Solaris .*)/
    );

    my ($version, $year);
    if ($release =~ m/Solaris 10 (\d+)\/(\d+)/) {
        $version = $1;
        $year = $2;
    } elsif ($release =~ /OpenSolaris 20(\d+)\.(\d+)\s/) {
        $version = $1;
        $year = $2;
    } else {
        return 0;
    }

    if ($year <= 7 and $version < 8) {
        return 0;
    }

    return 1;
}

1;
