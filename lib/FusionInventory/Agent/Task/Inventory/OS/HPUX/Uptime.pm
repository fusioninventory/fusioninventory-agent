package FusionInventory::Agent::Task::Inventory::OS::HPUX::Uptime;

use strict;
use warnings;

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
    my ($UYEAR, $UMONTH , $UDAY, $UHOUR, $UMIN, $USEC) = (gmtime ($seconds))[5,4,3,2,1,0];

    # Write in ISO format
    $uptime=sprintf "%02d-%02d-%02d %02d:%02d:%02d", ($UYEAR-70), $UMONTH, ($UDAY-1), $UHOUR, $UMIN, $USEC;

    chomp(my $DeviceType =`uname -m`);
    $inventory->setHardware({ DESCRIPTION => "$DeviceType/$uptime" });
}

1;
