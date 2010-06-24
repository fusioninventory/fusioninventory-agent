package FusionInventory::Agent::Task::Inventory::OS::HPUX::Uptime;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run("uptime") &&
        can_run ("uname");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    # Uptime
    my $uptime = `uptime`;
    my $seconds = 0;
    if ( $uptime =~ /.*\sup\s((\d+)\sdays\D+)?(\d{1,2}):(\d{1,2}).*/ ) {
        $seconds += $2 * 24 * 3600;
        $seconds += $3 * 3600;
        $seconds += $4 * 60;
    }

    # Uptime conversion
    my ($uyear, $umonth , $uday, $uhour, $umin, $usec) =
        (gmtime ($seconds))[5,4,3,2,1,0];

    # Write in ISO format
    $uptime = getFormatedDate(
        ($uyear-70), $umonth, ($uday-1), $uhour, $umin, $usec
    );

    chomp(my $DeviceType =`uname -m`);
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
